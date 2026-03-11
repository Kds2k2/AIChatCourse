//
//  ChatView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 05.01.2026.
//

import SwiftUI

struct ChatView: View {
    
    @State var viewModel: ChatViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(DependencyContainer.self) private var container
    
    var chat: ChatModel?
    var avatarId: String
    
    var body: some View {
        VStack(spacing: 10) {
            messagesSection
            textFieldSection
        }
        .navigationTitle(viewModel.avatar?.name ?? "")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                settingsButton
            }
        }
        .screenAppearAnalytics(name: "ChatView")
        .showCustomAlert(alert: $viewModel.showAlert)
        .showModal($viewModel.showProfileModel) {
            if let avatar = viewModel.avatar {
                profileModal(avatar: avatar)
            }
        }
        .sheet(isPresented: $viewModel.showPaywall, content: {
            PaywallView(viewModel: PaywallViewModel(interactor: CoreInteractor(container: container)))
        })
        .onFirstAppear {
            viewModel.onViewFirstAppear(chat: chat)
        }
        .onDisappear {
            viewModel.stopListenChatMessages()
        }
        .task {
            await viewModel.loadAvatar(avatarId: avatarId)
        }
        .task {
            await viewModel.loadChat(avatarId: avatarId)
            await viewModel.startListenChatMessages()
        }
    }
    
    // MARK: - Views
    private var messagesSection: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(viewModel.chatMessages, id: \.self) { message in
                    if viewModel.messageIsDelayed(message: message) {
                        timeStampView(date: message.createdAtCalculated)
                    }
                    
                    let isCurrentUser = viewModel.isCurrentUser(message: message)
                    ChatBubbleViewBuilder(
                        message: message,
                        isCurrentUser: isCurrentUser,
                        currentUserProfileColor: viewModel.currentUser?.profileColorCalculated ?? .accent,
                        imageName: isCurrentUser ? nil : viewModel.avatar?.profileImageName,
                        onImagePressed: viewModel.onProfileImagePressed
                    )
                    .onAppear {
                        viewModel.onMessageDidAppear(message: message)
                    }
                    .id(message.id)
                }
                
                if viewModel.isGeneratingResponse {
                    ChatBubbleViewBuilder(
                        message: ChatMessageModel.emptyMock,
                        isCurrentUser: false,
                        currentUserProfileColor: viewModel.currentUser?.profileColorCalculated ?? .accent,
                        imageName: viewModel.avatar?.profileImageName,
                        onImagePressed: viewModel.onProfileImagePressed
                    )
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 8)
            .rotationEffect(.degrees(180))
        }
        .rotationEffect(.degrees(180))
        .scrollPosition(id: $viewModel.scrollPosition, anchor: .center)
        .animation(.default, value: viewModel.chatMessages.count)
        .animation(.smooth, value: viewModel.isGeneratingResponse)
        .animation(.default, value: viewModel.scrollPosition)
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
        .lineLimit(1)
        .minimumScaleFactor(0.3)
    }
    
    private var textFieldSection: some View {
        TextField("Say something...", text: $viewModel.textFieldText)
            .autocorrectionDisabled()
            .padding(12)
            .padding(.trailing, 40)
            .accessibilityIdentifier("ChatTextField")
            .overlay(alignment: .trailing, content: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .padding(.trailing, 4)
                    .foregroundStyle(.accent)
                    .anyButton {
                        viewModel.onSendMessagePressed(avatarId: avatarId)
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
                viewModel.onChatSettingPressed {
                    dismiss()
                }
            }
            .showCustomAlert(type: .confirmationDialog, alert: $viewModel.showChatSettings)
    }
    
    private func profileModal(avatar: AvatarModel) -> some View {
        ProfileModalView(
            imageName: avatar.profileImageName,
            title: avatar.name,
            subtitle: avatar.characterOption?.rawValue.capitalized,
            headline: avatar.characterDescription,
            onXmarkPressed: {
                viewModel.showProfileModel = false
            }
        )
        .padding(40)
        .transition(.slide)
    }
}

#Preview("Working chat, Not Premium") {
    NavigationStack {
        ChatView(
            viewModel: ChatViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)),
            chat: ChatModel.mock,
            avatarId: AvatarModel.mock.avatarId
        )
        .previewEnvironment()
    }
}

#Preview("Working chat, Premium") {
    let container = DevPreview.shared.container
    container.register(PurchaseManager.self, service: PurchaseManager(service: MockPurchaseService(activeEntitlements: [.mock])))
    
    return NavigationStack {
        ChatView(
            viewModel: ChatViewModel(interactor: CoreInteractor(container: container)),
            chat: ChatModel.mock,
            avatarId: AvatarModel.mock.avatarId
        )
        .previewEnvironment()
    }
}

#Preview("Slow AI") {
    let container = DevPreview.shared.container
    container.register(AIManager.self, service: AIManager(service: MockAIService(delay: 5)))
    container.register(PurchaseManager.self, service: PurchaseManager(service: MockPurchaseService(activeEntitlements: [.mock])))
    
    return NavigationStack {
        ChatView(
            viewModel: ChatViewModel(interactor: CoreInteractor(container: container)),
            chat: ChatModel.mock,
            avatarId: AvatarModel.mock.avatarId
        )
        .previewEnvironment()
    }
}

#Preview("Failed AI response") {
    let container = DevPreview.shared.container
    container.register(AIManager.self, service: AIManager(service: MockAIService(delay: 2, showError: true)))
    container.register(PurchaseManager.self, service: PurchaseManager(service: MockPurchaseService(activeEntitlements: [.mock])))
    
    return NavigationStack {
        ChatView(
            viewModel: ChatViewModel(interactor: CoreInteractor(container: container)),
            chat: ChatModel.mock,
            avatarId: AvatarModel.mock.avatarId
        )
        .previewEnvironment()
    }
}
