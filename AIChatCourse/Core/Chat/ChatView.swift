//
//  ChatView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 05.01.2026.
//

import SwiftUI

struct ChatView: View {
    
    @Environment(AvatarManager.self) private var avatarManager
    
    @State private var chatMessages: [ChatMessageModel] = ChatMessageModel.mocks
    @State private var avatar: AvatarModel?
    @State private var currentUser: UserModel? = .mock

    @State private var textFieldText: String = ""
    @State private var scrollPosition: String?

    @State private var showAlert: AnyAppAlert?
    @State private var showChatSettings: AnyAppAlert?

    @State private var showProfileModel: Bool = false
    
    var avatarId: String
    
    var body: some View {
        VStack(spacing: 10) {
            messagesSection
            textFieldSection
        }
        .navigationTitle(avatar?.name ?? "Chat")
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
        .task {
            await loadAvatar()
        }
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

    private var messagesSection: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(chatMessages, id: \.self) { message in
                    let isCurrentUser = message.authorId == currentUser?.userId
                    ChatBubbleViewBuilder(
                        message: message,
                        isCurrentUser: isCurrentUser,
                        imageName: isCurrentUser ? nil : avatar?.profileImageName,
                        onImagePressed: onProfileImagePressed
                    )
                    .id(message.id)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 8)
            .rotationEffect(.degrees(180))
        }
        .rotationEffect(.degrees(180))
        .scrollPosition(id: $scrollPosition, anchor: .center)
        .animation(.default, value: chatMessages.count)
        .animation(.default, value: scrollPosition)
    }
    
    private var textFieldSection: some View {
        TextField("Say something...", text: $textFieldText)
            .keyboardType(.alphabet)
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
    
    private func onSendMessagePressed() {
        guard let currentUser else { return }
        let content = textFieldText
        
        do {
            try TextValidationHelper.checkIfTextIsValid(text: content)
            
            let message = ChatMessageModel(
                id: UUID().uuidString,
                chatId: UUID().uuidString,
                authorId: currentUser.userId,
                content: content,
                seenByIds: nil,
                createdAt: .now
            )
            
            chatMessages.append(message)
            scrollPosition = message.id
            textFieldText = ""
        } catch {
            showAlert = AnyAppAlert(error: error)
        }
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
}

#Preview {
    NavigationStack {
        ChatView(avatarId: "")
            .environment(AvatarManager(remote: MockAvatarService()))
    }
}
