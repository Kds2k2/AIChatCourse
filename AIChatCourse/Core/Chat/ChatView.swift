//
//  ChatView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 05.01.2026.
//

import SwiftUI

struct ChatView: View {
    
    @Environment(UserManager.self) private var userManager
    @Environment(AuthManager.self) private var authManager
    @Environment(AIManager.self) private var aiManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(ChatManager.self) private var chatManager
    @Environment(LogManager.self) private var logManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var chatMessages: [ChatMessageModel] = []
    @State private var avatar: AvatarModel?
    @State private var currentUser: UserModel?
    @State var chat: ChatModel?
    
    @State private var textFieldText: String = ""
    @State private var scrollPosition: String?

    @State private var showAlert: AnyAppAlert?
    @State private var showChatSettings: AnyAppAlert?
    @State private var showProfileModel: Bool = false
    
    @State private var isGeneratingResponse: Bool = false
    @State private var chatMessagesTask: Task<Void, Never>?
    
    var avatarId: String
    
    var body: some View {
        VStack(spacing: 10) {
            messagesSection
            textFieldSection
        }
        .navigationTitle(avatar?.name ?? "")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                settingsButton
            }
        }
        .screenAppearAnalytics(name: "ChatView")
        .showCustomAlert(alert: $showAlert)
        .showModal($showProfileModel) {
            if let avatar {
                profileModal(avatar: avatar)
            }
        }
        .onAppear { loadCurrentUser() }
        .onDisappear {
            chatMessagesTask?.cancel()
            chatMessagesTask = nil
        }
        .task {
            await loadAvatar()
        }
        .task {
            await loadChat()
            await listenChatMessages()
        }
    }
    
    // MARK: - Loading Data
    private func loadCurrentUser() {
        currentUser = userManager.currentUser
    }
    
    private func loadAvatar() async {
        logManager.trackEvent(event: Event.loadAvatarsStart)
        do {
            let avatar = try await avatarManager.getAvatar(id: avatarId)
            logManager.trackEvent(event: Event.loadAvatarsSuccess(avatar: avatar))
            
            self.avatar = avatar
            try? await avatarManager.addRecentAvatar(avatar: avatar)
        } catch {
            logManager.trackEvent(event: Event.loadAvatarsFail(error: error))
        }
    }
    
    private func loadChat() async {
        logManager.trackEvent(event: Event.loadChatStart)
        do {
            let uid = try authManager.getAuthId()
            chat = try await chatManager.getChat(userId: uid, avatarId: avatarId)
            logManager.trackEvent(event: Event.loadChatSuccess(chat: chat))
        } catch {
            logManager.trackEvent(event: Event.loadChatFail(error: error))
        }
    }
    
    private func listenChatMessages() async {
        logManager.trackEvent(event: Event.loadMessagesStart)
        chatMessagesTask?.cancel()
        
        chatMessagesTask = Task {
            do {
                let chatId = try getChatId()
                for try await value in chatManager.streamChatMessages(chatId: chatId) {
                    self.chatMessages = value.sortedByKeyPath(keyPath: \.createdAtCalculated, order: .ascending)
                    withAnimation(.easeOut(duration: 0.25)) {
                        scrollPosition = chatMessages.last?.id
                    }
                }
            } catch is CancellationError {
                // expected
            } catch {
                logManager.trackEvent(event: Event.loadMessagesFail(error: error))
            }
        }
    }
    
    private func getChatId() throws -> String {
        guard let chat else {
            throw ChatViewError.noChat
        }
        
        return chat.id
    }
    
    // MARK: - Views
    private var messagesSection: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(chatMessages, id: \.self) { message in
                    if messageIsDelayed(message: message) {
                        timeStampView(date: message.createdAtCalculated)
                    }
                    
                    let isCurrentUser = message.authorId == authManager.auth?.uid
                    ChatBubbleViewBuilder(
                        message: message,
                        isCurrentUser: isCurrentUser,
                        currentUserProfileColor: currentUser?.profileColorCalculated ?? .accent,
                        imageName: isCurrentUser ? nil : avatar?.profileImageName,
                        onImagePressed: onProfileImagePressed
                    )
                    .onAppear {
                        onMessageDidAppear(message: message)
                    }
                    .id(message.id)
                }
                
                if isGeneratingResponse {
                    ChatBubbleViewBuilder(
                        message: ChatMessageModel.emptyMock,
                        isCurrentUser: false,
                        currentUserProfileColor: currentUser?.profileColorCalculated ?? .accent,
                        imageName: avatar?.profileImageName,
                        onImagePressed: onProfileImagePressed
                    )
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 8)
            .rotationEffect(.degrees(180))
        }
        .rotationEffect(.degrees(180))
        .scrollPosition(id: $scrollPosition, anchor: .center)
        .animation(.default, value: chatMessages.count)
        .animation(.smooth, value: isGeneratingResponse)
        .animation(.default, value: scrollPosition)
    }
    
    private func timeStampView(date: Date) -> some View {
        Group {
            Text(date.formatted(date: .abbreviated, time: .omitted))
            +
            Text(" - ")
            +
            Text(date.formatted(date: .omitted, time: .shortened))
        }
        .foregroundStyle(.secondary)
        .font(.callout)
    }
    
    private var textFieldSection: some View {
        TextField("Say something...", text: $textFieldText)
            .autocorrectionDisabled()
            .padding(12)
            .padding(.trailing, 40)
            .overlay(alignment: .trailing, content: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .padding(.trailing, 4)
                    .foregroundStyle(.accent)
                    .anyButton {
                        onSendMessagePressed()
                    }
            })
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 100)
                        .fill(Color(uiColor: .systemBackground))
                    
                    RoundedRectangle(cornerRadius: 100)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(uiColor: .secondarySystemBackground))
    }
    
    private var settingsButton: some View {
        Image(systemName: "ellipsis")
            .foregroundStyle(.accent)
            .padding(8)
            .anyButton {
                onChatSettingPressed()
            }
            .showCustomAlert(type: .confirmationDialog, alert: $showChatSettings)
    }
    
    private func profileModal(avatar: AvatarModel) -> some View {
        ProfileModalView(
            imageName: avatar.profileImageName,
            title: avatar.name,
            subtitle: avatar.characterOption?.rawValue.capitalized,
            headline: avatar.characterDescription,
            onXmarkPressed: {
                showProfileModel = false
            }
        )
        .padding(40)
        .transition(.slide)
    }
    
    // MARK: - Actions
    private func onMessageDidAppear(message: ChatMessageModel) {
        Task {
            do {
                let uid = try authManager.getAuthId()
                let chatId = try getChatId()
                
                guard !message.hasBeenSeenBy(userId: uid) else {
                    return
                }
                
                try await chatManager.markChatMessageAsSeen(chatId: chatId, messageId: message.id, userId: uid)
            } catch {
                logManager.trackEvent(event: Event.messageSeenFail(error: error))
            }
        }
    }
    
    private func messageIsDelayed(message: ChatMessageModel) -> Bool {
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
    
    private func onSendMessagePressed() {
        let content = textFieldText
        logManager.trackEvent(event: Event.sendMessageStart(chat: chat, avatar: avatar))
        
        Task {
            do {
                let userId = try authManager.getAuthId()
                try TextValidationHelper.checkIfTextIsValid(text: content)
                
                // If chat is nil, then create a new chat
                // If still nil, throw error
                if chat == nil {
                    chat = try await createNewChat(userId: userId)
                    await listenChatMessages()
                }
                
                guard let chat else {
                    throw ChatViewError.noChat
                }
                
                // Create User Message
                let newChatMessage = AIChatModel(role: .user, message: content)
                let message = ChatMessageModel.newUserMessage(chatId: chat.id, userId: userId, message: newChatMessage)
                
                // Upload User Message
                try await chatManager.addChatMessage(message: message)
                logManager.trackEvent(event: Event.sendMessageSent(chat: chat, avatar: avatar, message: message))
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
                let response = try await aiManager.generateText(chats: aiChats)
                let newAIMessage = ChatMessageModel.newAIMessage(chatId: chat.id, avatarId: avatarId, message: response)
                logManager.trackEvent(event: Event.sendMessageResponse(chat: chat, avatar: avatar, message: newAIMessage))
                
                // Upload AI Response
                try await chatManager.addChatMessage(message: newAIMessage)
                logManager.trackEvent(event: Event.sendMessageReponseSent(chat: chat, avatar: avatar, message: newAIMessage))
            } catch {
                showAlert = AnyAppAlert(error: error)
                logManager.trackEvent(event: Event.sendMessageFail(error: error))
            }
            
            isGeneratingResponse = false
        }
    }
    
    private func createNewChat(userId: String) async throws -> ChatModel {
        logManager.trackEvent(event: Event.createChatStart)
        let newChat = ChatModel.new(userId: userId, avatarId: avatarId)
        try await chatManager.createNewChat(chat: newChat)
        return newChat
    }
    
    private func onChatSettingPressed() {
        logManager.trackEvent(event: Event.chatSettingsPressed)
        showChatSettings = AnyAppAlert(
            title: "",
            subtitle: "What would you like to do?",
            buttons: {
                AnyView(
                    Group {
                        Button("Report User / Chat", role: .destructive) {
                            onReportChatPressed()
                        }
                        Button("Delete Chat", role: .destructive) {
                            onDeleteChatPressed()
                        }
                    }
                )
            }
        )
    }
    
    private func onReportChatPressed() {
        logManager.trackEvent(event: Event.reportChatStart)
        Task {
            do {
                let uid = try authManager.getAuthId()
                let chatId = try getChatId()
                try await chatManager.reportChat(chatId: chatId, userId: uid)
                logManager.trackEvent(event: Event.reportChatSuccess)
                
                showAlert = AnyAppAlert(
                    title: "Reported",
                    subtitle: "We will review the chat shortly. You may leave the chat at eny time. Thanks for bringing this to our attention.",
                    buttons: nil
                )
            } catch {
                logManager.trackEvent(event: Event.reportChatFail(error: error))
                showAlert = AnyAppAlert(
                    title: "Something went wrong.",
                    subtitle: "Please check your internet connection and try again.",
                    buttons: nil
                )
            }
        }
    }
    
    private func onDeleteChatPressed() {
        logManager.trackEvent(event: Event.deleteChatStart)
        Task {
            do {
                let chatId = try getChatId()
                try await chatManager.deleteChat(chatId: chatId)
                logManager.trackEvent(event: Event.deleteChatSuccess)
                dismiss()
            } catch {
                logManager.trackEvent(event: Event.deleteChatFail(error: error))
                showAlert = AnyAppAlert(
                    title: "Something went wrong.",
                    subtitle: "Please check your internet connection and try again.",
                    buttons: nil
                )
            }
        }
    }
    
    private func onProfileImagePressed() {
        logManager.trackEvent(event: Event.profileImagePressed(avatar: avatar))
        showProfileModel = true
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
            case .sendMessageStart(chat: let chat, avatar: let avatar):
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

#Preview("Working chat") {
    NavigationStack {
        ChatView(chat: ChatModel.mock, avatarId: AvatarModel.mock.avatarId)
            .previewEnvironment(isSignedIn: true)
    }
}

#Preview("Slow AI") {
    NavigationStack {
        ChatView(avatarId: AvatarModel.mock.avatarId)
            .environment(AIManager(service: MockAIService(delay: 5)))
            .previewEnvironment()
    }
}

#Preview("Failed AI response") {
    NavigationStack {
        ChatView(avatarId: AvatarModel.mock.avatarId)
            .environment(AIManager(service: MockAIService(delay: 2, showError: true)))
            .previewEnvironment()
    }
}
