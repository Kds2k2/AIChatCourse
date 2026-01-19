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
    
    private func loadCurrentUser() {
        currentUser = userManager.currentUser
    }
    
    private func loadAvatar() async {
        do {
            let avatar = try await avatarManager.getAvatar(id: avatarId)
            self.avatar = avatar
            try? await avatarManager.addRecentAvatar(avatar: avatar)
        } catch {
            print("Error loading avatar: \(error)")
        }
    }
    
    private func loadChat() async {
        do {
            let uid = try authManager.getAuthId()
            chat = try await chatManager.getChat(userId: uid, avatarId: avatarId)
            print("Success loading chat.")
        } catch {
            print("Error loading chat: \(error)")
        }
    }
    
    private func listenChatMessages() async {
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
                print("Failed to attach chat messages to chat.")
            }
        }
    }
    
    private func getChatId() throws -> String {
        guard let chat else {
            throw ChatViewError.noChat
        }
        
        return chat.id
    }
    
    private var messagesSection: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(chatMessages, id: \.self) { message in
                    let isCurrentUser = message.authorId == authManager.auth?.uid
                    ChatBubbleViewBuilder(
                        message: message,
                        isCurrentUser: isCurrentUser,
                        currentUserProfileColor: currentUser?.profileColorCalculated ?? .accent,
                        imageName: isCurrentUser ? nil : avatar?.profileImageName,
                        onImagePressed: onProfileImagePressed
                    )
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
        .scrollPosition(id: $scrollPosition, anchor: .top)
        .animation(.default, value: chatMessages.count)
        .animation(.smooth, value: isGeneratingResponse)
        .animation(.default, value: scrollPosition)
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
    
    private func onSendMessagePressed() {
        let content = textFieldText
        
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
                textFieldText = ""
                
                // Generate AI Response
                isGeneratingResponse = true
                var aiChats = chatMessages.compactMap({ $0.content })
                if let avatarDescription = avatar?.characterDescription, let avatarName = avatar?.name {
                    let messageContent = "Your name is \(avatarName). You are \(avatarDescription.lowercased())"
                    let systemMessage = AIChatModel(role: .system, message: messageContent)
                    aiChats.insert(systemMessage, at: 0)
                }
                
                let response = try await aiManager.generateText(chats: aiChats)
                
                // Upload AI Response
                let newAIMessage = ChatMessageModel.newAIMessage(chatId: chat.id, avatarId: avatarId, message: response)
                try await chatManager.addChatMessage(message: newAIMessage)
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
            
            isGeneratingResponse = false
        }
    }
    
    private func createNewChat(userId: String) async throws -> ChatModel {
        let newChat = ChatModel.new(userId: userId, avatarId: avatarId)
        try await chatManager.createNewChat(chat: newChat)
        return newChat
    }
    
    private func onChatSettingPressed() {
        showChatSettings = AnyAppAlert(
            title: "",
            subtitle: "What would you like to do?",
            buttons: {
                AnyView(
                    Group {
                        Button("Report User / Chat", role: .destructive) {
                            // action
                        }
                        Button("Delete Chat", role: .destructive) {
                            // action
                        }
                    }
                )
            }
        )
    }
    
    private func onProfileImagePressed() {
        showProfileModel = true
    }
    
    enum ChatViewError: LocalizedError {
        case noChat
    }
}

#Preview("Working chat") {
    NavigationStack {
        ChatView(avatarId: "")
            .previewEnvironment()
    }
}

#Preview("Slow AI") {
    NavigationStack {
        ChatView(avatarId: "")
            .environment(AIManager(service: MockAIService(delay: 5)))
            .previewEnvironment()
    }
}

#Preview("Failed AI response") {
    NavigationStack {
        ChatView(avatarId: "")
            .environment(AIManager(service: MockAIService(delay: 2, showError: true)))
            .previewEnvironment()
    }
}
