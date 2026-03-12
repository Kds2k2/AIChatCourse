//
//  ChatsView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 31.12.2025.
//

import SwiftUI

struct ChatsView: View {
    
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: ChatsViewModel
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            List {
                if !viewModel.recentAvatars.isEmpty {
                    recentsSection
                }
                
                chatsSection
            }
            .navigationTitle("Chats")
            .navigationDestinationForTabBarModule(path: $viewModel.path)
            .screenAppearAnalytics(name: "ChatsView")
            .onAppear {
                viewModel.loadRecentAvatars()
            }
            .task {
                await viewModel.loadChats()
            }
        }
    }
    
    // MARK: - Views
    private var chatsSection: some View {
        Section {
            if viewModel.isLoadingChats {
                ProgressView()
                    .padding(40)
                    .frame(maxWidth: .infinity)
                    .removeListRowFormatting()
            } else {
                if viewModel.chats.isEmpty {
                    Text("Your chats will appear here!")
                        .foregroundStyle(.secondary)
                        .font(.title3)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(40)
                        .removeListRowFormatting()
                } else {
                    ForEach(viewModel.chats, id: \.self) { chat in
                        ChatRowCellViewBuilder(
                            viewModel: ChatRowCellViewModel(
                                interactor: CoreInteractor(
                                    container: container
                                )
                            ),
                            chat: chat
                        )
                        .anyButton(.highlight, action: {
                            viewModel.onChatPressed(chat: chat)
                        })
                        .removeListRowFormatting()
                    }
                }
            }
        } header: {
            Text(viewModel.chats.isEmpty ? "" : "Chats")
        }
    }
    
    private var recentsSection: some View {
        Section {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 8) {
                    ForEach(viewModel.recentAvatars, id: \.self) { avatar in
                        if let imageName = avatar.profileImageName {
                            VStack(spacing: 8) {
                                ImageLoaderView(urlString: imageName)
                                    .aspectRatio(1, contentMode: .fit)
                                    .clipShape(Circle())
                                    .frame(minHeight: 60)
                                
                                Text(avatar.name ?? "")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            .anyButton(.press) {
                                viewModel.onAvatarPresser(avatar: avatar)
                            }
                        }
                    }
                }
                .padding(.top, 12)
            }
            .scrollIndicators(.hidden)
            .frame(height: 120)
            .removeListRowFormatting()
        } header: {
            Text("Recents")
        }
    }
}

// MARK: - Previews
#Preview("Has data") {
    let container = DevPreview.shared.container
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: .mock(isAnonymous: true))))
    
    return ChatsView(viewModel: ChatsViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
}

#Preview("No data") {
    let container = DevPreview.shared.container
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: .mock(isAnonymous: true))))
    container.register(ChatManager.self, service: ChatManager(service: MockChatService(chats: [])))
    container.register(AvatarManager.self, service: AvatarManager(remote: MockAvatarService(avatars: []), local: MockLocalAvatarPersistence(avatars: [])))
    
    return ChatsView(viewModel: ChatsViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
}

#Preview("Slow loading chats") {
    let container = DevPreview.shared.container
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: .mock(isAnonymous: true))))
    container.register(ChatManager.self, service: ChatManager(service: MockChatService(delay: 5)))
    
    return ChatsView(viewModel: ChatsViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
}

#Preview("Error loading chats") {
    let container = DevPreview.shared.container
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: .mock(isAnonymous: true))))
    container.register(ChatManager.self, service: ChatManager(service: MockChatService(delay: 5, showError: true)))
    
    return ChatsView(viewModel: ChatsViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
}
