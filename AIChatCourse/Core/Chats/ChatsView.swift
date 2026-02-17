//
//  ChatsView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 31.12.2025.
//

import SwiftUI

struct ChatsView: View {
    
    @Environment(AuthManager.self) private var authManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(ChatManager.self) private var chatManager
    @Environment(LogManager.self) private var logManager
    
    @State private var chats: [ChatModel] = []
    @State private var isLoadingChats: Bool = true
    @State private var recentAvatars: [AvatarModel] = []
    
    @State private var path: [NavigationPathOption] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                if !recentAvatars.isEmpty {
                    recentsSection
                }
                
                chatsSection
            }
            .navigationTitle("Chats")
            .navigationDestinationForCoreModule(path: $path)
            .screenAppearAnalytics(name: "ChatsView")
            .onAppear {
                loadRecentAvatars()
            }
            .task {
                await loadChats()
            }
        }
    }
    
    // MARK: - Loading
    private func loadRecentAvatars() {
        logManager.trackEvent(event: Event.loadAvatarsStart)
        do {
            recentAvatars = try avatarManager.getRecentAvatars()
            logManager.trackEvent(event: Event.loadAvatarsSuccess)
        } catch {
            logManager.trackEvent(event: Event.loadAvatarsFail(error: error))
        }
    }
    
    private func loadChats() async {
        logManager.trackEvent(event: Event.loadChatsStart)
        do {
            let uid = try authManager.getAuthId()
            chats = try await chatManager.getAllChats(userId: uid) // .sorted(by: { $0.updatedAt > $1.updatedAt })
                .sortedByKeyPath(keyPath: \.updatedAt, order: .descending)
            logManager.trackEvent(event: Event.loadChatsSuccess)
        } catch {
            logManager.trackEvent(event: Event.loadChatsFail(error: error))
        }
        isLoadingChats = false
    }
    
    // MARK: - Views
    private var chatsSection: some View {
        Section {
            if isLoadingChats {
                ProgressView()
                    .padding(40)
                    .frame(maxWidth: .infinity)
                    .removeListRowFormatting()
            } else {
                if chats.isEmpty {
                    Text("Your chats will appear here!")
                        .foregroundStyle(.secondary)
                        .font(.title3)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(40)
                        .removeListRowFormatting()
                } else {
                    ForEach(chats, id: \.self) { chat in
                        ChatRowCellViewBuilder(
                            chat: chat,
                            currentUserId: authManager.auth?.uid,
                            getAvatar: {
                                try? await avatarManager.getAvatar(id: chat.avatarId)
                            },
                            getLastChatMessage: {
                                try? await chatManager.getLastChatMessage(chatId: chat.id)
                            }
                        )
                        .anyButton(.highlight, action: {
                            onChatPressed(chat: chat)
                        })
                        .removeListRowFormatting()
                    }
                }
            }
        } header: {
            Text(chats.isEmpty ? "" : "Chats")
        }
    }
    
    private var recentsSection: some View {
        Section {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 8) {
                    ForEach(recentAvatars, id: \.self) { avatar in
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
                                onAvatarPresser(avatar: avatar)
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
    
    // MARK: - Actions
    private func onChatPressed(chat: ChatModel) {
        path.append(.chat(avatarId: chat.avatarId, chat: chat))
        logManager.trackEvent(event: Event.chatPressed(chat: chat))
    }
    
    private func onAvatarPresser(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
        logManager.trackEvent(event: Event.avatarPressed(avatar: avatar))
    }
    
    // MARK: - Logs
    enum Event: LoggableEvent {
        case loadAvatarsStart, loadAvatarsSuccess, loadAvatarsFail(error: Error)
        case loadChatsStart, loadChatsSuccess, loadChatsFail(error: Error)
        case chatPressed(chat: ChatModel), avatarPressed(avatar: AvatarModel)
        
        static var screenName: String = "ChatsView"
        
        var eventName: String {
            switch self {
            case .loadAvatarsStart:         return "\(Event.screenName)_LoadAvatars_Start"
            case .loadAvatarsSuccess:       return "\(Event.screenName)_LoadAvatars_Success"
            case .loadAvatarsFail:          return "\(Event.screenName)_LoadAvatars_Fail"
            case .loadChatsStart:           return "\(Event.screenName)_LoadChats_Start"
            case .loadChatsSuccess:         return "\(Event.screenName)_LoadChats_Success"
            case .loadChatsFail:            return "\(Event.screenName)_LoadChats_Fail"
            case .chatPressed:              return "\(Event.screenName)_Chat_Pressed"
            case .avatarPressed:            return "\(Event.screenName)_Avatar_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadChatsFail(error: let error), .loadAvatarsFail(error: let error):
                return error.eventParameters
            case .chatPressed(chat: let chat):
                return chat.eventParameters
            case .avatarPressed(avatar: let avatar):
                return avatar.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadChatsFail, .loadAvatarsFail:
                    .severe
            default:
                    .analytic
            }
        }
    }
}

// MARK: - Previews
#Preview("Has data") {
    ChatsView()
        .environment(AuthManager(service: MockAuthService(user: .mock(isAnonymous: true))))
        .previewEnvironment()
}

#Preview("No data") {
    ChatsView()
        .environment(
            AvatarManager(
                remote: MockAvatarService(avatars: []),
                local: MockLocalAvatarPersistence(avatars: [])
            )
        )
        .environment(ChatManager(service: MockChatService(chats: [])))
        .environment(AuthManager(service: MockAuthService(user: .mock(isAnonymous: true))))
        .previewEnvironment()
}

#Preview("Slow loading chats") {
    ChatsView()
        .environment(ChatManager(service: MockChatService(delay: 5)))
        .environment(AuthManager(service: MockAuthService(user: .mock(isAnonymous: true))))
        .previewEnvironment()
}

#Preview("Error loading chats") {
    ChatsView()
        .environment(ChatManager(service: MockChatService(delay: 5, showError: true)))
        .environment(AuthManager(service: MockAuthService(user: .mock(isAnonymous: true))))
        .previewEnvironment()
}
