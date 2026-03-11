//
//  ChatViewModel.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 11.03.2026.
//

import SwiftUI

@MainActor
protocol ChatInteractor {
    var currentUser: UserModel? { get }
    var auth: UserAuthInfo? { get }
    var isPremium: Bool { get }
    
    func trackEvent(event: LoggableEvent)
    func getAvatar(id: String) async throws -> AvatarModel
    func addRecentAvatar(avatar: AvatarModel) async throws
    func getAuthId() throws -> String
    func getChat(userId: String, avatarId: String) async throws -> ChatModel?
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], any Error>
    func markChatMessageAsSeen(chatId: String, messageId: String, userId: String) async throws
    func addChatMessage(message: ChatMessageModel) async throws
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel
    func createNewChat(chat: ChatModel) async throws
    func reportChat(chatId: String, userId: String) async throws
    func deleteChat(chatId: String) async throws
}

extension CoreInteractor: ChatInteractor { }

@Observable
@MainActor
class ChatViewModel {
    let interactor: ChatInteractor
    
    private(set) var chat: ChatModel?
    private(set) var chatMessages: [ChatMessageModel] = []
    private(set) var avatar: AvatarModel?
    private(set) var currentUser: UserModel?
    private(set) var isGeneratingResponse: Bool = false
    private(set) var chatMessagesTask: Task<Void, Never>?
    
    var textFieldText: String = ""
    var scrollPosition: String?
    var showAlert: AnyAppAlert?
    var showChatSettings: AnyAppAlert?
    var showProfileModel: Bool = false
    var showPaywall: Bool = false
    
    init(interactor: ChatInteractor) {
        self.interactor = interactor
    }
    
    // MARK: - Tasks
    func onViewFirstAppear(chat: ChatModel?) {
        self.currentUser = interactor.currentUser
        self.chat = chat
    }
    
    func loadAvatar(avatarId: String) async {
        interactor.trackEvent(event: Event.loadAvatarsStart)
        do {
            let avatar = try await interactor.getAvatar(id: avatarId)
            interactor.trackEvent(event: Event.loadAvatarsSuccess(avatar: avatar))
            
            self.avatar = avatar
            try? await interactor.addRecentAvatar(avatar: avatar)
        } catch {
            interactor.trackEvent(event: Event.loadAvatarsFail(error: error))
        }
    }
    
    func loadChat(avatarId: String) async {
        interactor.trackEvent(event: Event.loadChatStart)
        do {
            let uid = try interactor.getAuthId()
            self.chat = try await interactor.getChat(userId: uid, avatarId: avatarId)
            interactor.trackEvent(event: Event.loadChatSuccess(chat: chat))
        } catch {
            interactor.trackEvent(event: Event.loadChatFail(error: error))
        }
    }
    
    func startListenChatMessages() async {
        interactor.trackEvent(event: Event.loadMessagesStart)
        chatMessagesTask?.cancel()
        
        chatMessagesTask = Task {
            do {
                let chatId = try getChatId()
                for try await value in interactor.streamChatMessages(chatId: chatId) {
                    self.chatMessages = value.sortedByKeyPath(keyPath: \.createdAtCalculated, order: .ascending)
                    withAnimation(.easeOut(duration: 0.25)) {
                        scrollPosition = chatMessages.last?.id
                    }
                }
            } catch is CancellationError {
                // expected
            } catch {
                interactor.trackEvent(event: Event.loadMessagesFail(error: error))
            }
        }
    }
    
    func stopListenChatMessages() {
        chatMessagesTask?.cancel()
        chatMessagesTask = nil
    }
    
    // MARK: - Public Func
    func isCurrentUser(message: ChatMessageModel) -> Bool {
        message.authorId == interactor.auth?.uid
    }
    
    func messageIsDelayed(message: ChatMessageModel) -> Bool {
        let currentDate = message.createdAtCalculated
        
        guard let index = chatMessages.firstIndex(where: { $0.id == message.id }),
              chatMessages.indices.contains(index - 1)
        else {
            return false
        }
        
        let previousDate = chatMessages[index - 1].createdAtCalculated
        let timeDiff = currentDate.timeIntervalSince(previousDate)
        
        // 45 minutes, also could check for date components for same day or etc.
        let threshold: TimeInterval = 60 * 45
        return timeDiff > threshold
    }
    
    // MARK: - Actions
    func onMessageDidAppear(message: ChatMessageModel) {
        Task {
            do {
                let uid = try interactor.getAuthId()
                let chatId = try getChatId()
                
                guard !message.hasBeenSeenBy(userId: uid) else {
                    return
                }
                
                try await interactor.markChatMessageAsSeen(chatId: chatId, messageId: message.id, userId: uid)
            } catch {
                interactor.trackEvent(event: Event.messageSeenFail(error: error))
            }
        }
    }
    
    func onSendMessagePressed(avatarId: String) {
        let content = textFieldText
        interactor.trackEvent(event: Event.sendMessageStart(chat: chat, avatar: avatar))
        
        Task {
            do {
                // Condition for showing paywall
                if !interactor.isPremium && chatMessages.count >= 3 {
                    interactor.trackEvent(event: Event.sendMessagePaywall(chat: chat, avatar: avatar))
                    showPaywall = true
                    return
                }
                
                let userId = try interactor.getAuthId()
                try TextValidationHelper.checkIfTextIsValid(text: content)
                
                // If chat is nil, then create a new chat
                // If still nil, throw error
                if chat == nil {
                    chat = try await createNewChat(userId: userId, avatarId: avatarId)
                    await startListenChatMessages()
                }
                
                guard let chat else {
                    throw ChatViewError.noChat
                }
                
                // Create User Message
                let newChatMessage = AIChatModel(role: .user, message: content)
                let message = ChatMessageModel.newUserMessage(chatId: chat.id, userId: userId, message: newChatMessage)
                
                // Upload User Message
                try await interactor.addChatMessage(message: message)
                interactor.trackEvent(event: Event.sendMessageSent(chat: chat, avatar: avatar, message: message))
                textFieldText = ""
                
                // Generate AI Response
                isGeneratingResponse = true
                var aiChats = chatMessages.compactMap({ $0.content })
                if let avatarDescription = avatar?.characterDescription, let avatarName = avatar?.name {
                    let messageContent = "Your name is \(avatarName). You are \(avatarDescription.lowercased()). You have conversation with me in chat."
                    let systemMessage = AIChatModel(role: .system, message: messageContent)
                    aiChats.insert(systemMessage, at: 0)
                }
                
                // Create AI Response
                let response = try await interactor.generateText(chats: aiChats)
                let newAIMessage = ChatMessageModel.newAIMessage(chatId: chat.id, avatarId: avatarId, message: response)
                interactor.trackEvent(event: Event.sendMessageResponse(chat: chat, avatar: avatar, message: newAIMessage))
                
                // Upload AI Response
                try await interactor.addChatMessage(message: newAIMessage)
                interactor.trackEvent(event: Event.sendMessageReponseSent(chat: chat, avatar: avatar, message: newAIMessage))
            } catch {
                showAlert = AnyAppAlert(error: error)
                interactor.trackEvent(event: Event.sendMessageFail(error: error))
            }
            
            isGeneratingResponse = false
        }
    }
    
    func onChatSettingPressed(onDidDeleteChat: @escaping () -> Void) {
        interactor.trackEvent(event: Event.chatSettingsPressed)
        showChatSettings = AnyAppAlert(
            title: "",
            subtitle: "What would you like to do?",
            buttons: {
                AnyView(
                    Group {
                        Button("Report User / Chat", role: .destructive) {
                            self.onReportChatPressed()
                        }
                        Button("Delete Chat", role: .destructive) {
                            self.onDeleteChatPressed(onDidDeleteChat: onDidDeleteChat)
                        }
                    }
                )
            }
        )
    }
    
    func onReportChatPressed() {
        interactor.trackEvent(event: Event.reportChatStart)
        Task {
            do {
                let uid = try interactor.getAuthId()
                let chatId = try getChatId()
                try await interactor.reportChat(chatId: chatId, userId: uid)
                interactor.trackEvent(event: Event.reportChatSuccess)
                
                showAlert = AnyAppAlert(
                    title: "Reported",
                    subtitle: "We will review the chat shortly. You may leave the chat at eny time. Thanks for bringing this to our attention.",
                    buttons: nil
                )
            } catch {
                interactor.trackEvent(event: Event.reportChatFail(error: error))
                showAlert = AnyAppAlert(
                    title: "Something went wrong.",
                    subtitle: "Please check your internet connection and try again.",
                    buttons: nil
                )
            }
        }
    }
    
    func onDeleteChatPressed(onDidDeleteChat: @escaping () -> Void) {
        interactor.trackEvent(event: Event.deleteChatStart)
        Task {
            do {
                let chatId = try getChatId()
                try await interactor.deleteChat(chatId: chatId)
                interactor.trackEvent(event: Event.deleteChatSuccess)
                onDidDeleteChat()
            } catch {
                interactor.trackEvent(event: Event.deleteChatFail(error: error))
                showAlert = AnyAppAlert(
                    title: "Something went wrong.",
                    subtitle: "Please check your internet connection and try again.",
                    buttons: nil
                )
            }
        }
    }
    
    func onProfileImagePressed() {
        interactor.trackEvent(event: Event.profileImagePressed(avatar: avatar))
        showProfileModel = true
    }
    
    // MARK: - Private Func
    private func getChatId() throws -> String {
        guard let chat else {
            throw ChatViewError.noChat
        }
        
        return chat.id
    }
    
    private func createNewChat(userId: String, avatarId: String) async throws -> ChatModel {
        interactor.trackEvent(event: Event.createChatStart)
        let newChat = ChatModel.new(userId: userId, avatarId: avatarId)
        try await interactor.createNewChat(chat: newChat)
        return newChat
    }
    
    // MARK: - Error, Logs
    enum ChatViewError: LocalizedError {
        case noChat
    }
    
    enum Event: LoggableEvent {
        case loadAvatarsStart, loadAvatarsSuccess(avatar: AvatarModel), loadAvatarsFail(error: Error)
        case loadChatStart, loadChatSuccess(chat: ChatModel?), loadChatFail(error: Error)
        case loadMessagesStart, loadMessagesFail(error: Error)
        case messageSeenFail(error: Error)
        case sendMessageStart(chat: ChatModel?, avatar: AvatarModel?), sendMessageFail(error: Error)
        case sendMessageSent(chat: ChatModel?, avatar: AvatarModel?, message: ChatMessageModel)
        case sendMessageResponse(chat: ChatModel?, avatar: AvatarModel?, message: ChatMessageModel)
        case sendMessageReponseSent(chat: ChatModel?, avatar: AvatarModel?, message: ChatMessageModel)
        case sendMessagePaywall(chat: ChatModel?, avatar: AvatarModel?)
        case createChatStart
        case chatSettingsPressed
        case reportChatStart, reportChatSuccess, reportChatFail(error: Error)
        case deleteChatStart, deleteChatSuccess, deleteChatFail(error: Error)
        case profileImagePressed(avatar: AvatarModel?)
        
        static var screenName: String = "ChatView"
        
        var eventName: String {
            switch self {
            case .loadAvatarsStart:         return "\(Event.screenName)_LoadAvatars_Start"
            case .loadAvatarsSuccess:       return "\(Event.screenName)_LoadAvatars_Success"
            case .loadAvatarsFail:          return "\(Event.screenName)_LoadAvatars_Fail"
            case .loadChatStart:            return "\(Event.screenName)_LoadChat_Start"
            case .loadChatSuccess:          return "\(Event.screenName)_LoadChat_Success"
            case .loadChatFail:             return "\(Event.screenName)_LoadChat_Fail"
            case .loadMessagesStart:        return "\(Event.screenName)_LoadMessages_Start"
            case .loadMessagesFail:         return "\(Event.screenName)_LoadMessages_Fail"
            case .messageSeenFail:          return "\(Event.screenName)_MessageSeen_Fail"
            case .sendMessageStart:         return "\(Event.screenName)_SendMessage_Start"
            case .sendMessageFail:          return "\(Event.screenName)_SendMessage_Fail"
            case .sendMessageSent:          return "\(Event.screenName)_SendMessage_Sent"
            case .sendMessageResponse:      return "\(Event.screenName)_SendMessage_Response"
            case .sendMessageReponseSent:   return "\(Event.screenName)_SendMessage_ReponseSent"
            case .sendMessagePaywall:       return "\(Event.screenName)_SendMessage_Paywall"
            case .createChatStart:          return "\(Event.screenName)_CreateChat_Start"
            case .chatSettingsPressed:      return "\(Event.screenName)_ChatSettings_Pressed"
            case .reportChatStart:          return "\(Event.screenName)_ReportChat_Start"
            case .reportChatSuccess:        return "\(Event.screenName)_ReportChat_Success"
            case .reportChatFail:           return "\(Event.screenName)_ReportChat_Fail"
            case .deleteChatStart:          return "\(Event.screenName)_DeleteChat_Start"
            case .deleteChatSuccess:        return "\(Event.screenName)_DeleteChat_Success"
            case .deleteChatFail:           return "\(Event.screenName)_DeleteChat_Fail"
            case .profileImagePressed:      return "\(Event.screenName)_ProfileImage_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadAvatarsFail(error: let error), .loadChatFail(error: let error), .loadMessagesFail(error: let error), .messageSeenFail(error: let error), .sendMessageFail(error: let error), .reportChatFail(error: let error), .deleteChatFail(error: let error):
                return error.eventParameters
            case .loadChatSuccess(chat: let chat):
                return chat?.eventParameters
            case .loadAvatarsSuccess(avatar: let avatar):
                return avatar.eventParameters
            case .sendMessageStart(chat: let chat, avatar: let avatar), .sendMessagePaywall(chat: let chat, avatar: let avatar):
                var dict = chat?.eventParameters ?? [:]
                dict.merge(avatar?.eventParameters)
                return dict
            case .sendMessageSent(chat: let chat, avatar: let avatar, message: let message), .sendMessageResponse(chat: let chat, avatar: let avatar, message: let message), .sendMessageReponseSent(chat: let chat, avatar: let avatar, message: let message):
                var dict = chat?.eventParameters ?? [:]
                dict.merge(avatar?.eventParameters)
                dict.merge(message.eventParameters)
                return dict
            case .profileImagePressed(avatar: let avatar):
                return avatar?.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadAvatarsFail, .loadMessagesFail, .messageSeenFail, .reportChatFail, .deleteChatFail:
                    .severe
            case .loadChatFail, .sendMessageFail:
                    .waring
            default:
                    .analytic
            }
        }
    }
}
