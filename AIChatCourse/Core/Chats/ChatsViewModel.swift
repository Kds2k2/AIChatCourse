//
//  ChatsViewModel.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 10.03.2026.
//

import SwiftUI

@MainActor
protocol ChatsInteractor {
    var auth: UserAuthInfo? { get }
    
    func trackEvent(event: LoggableEvent)
    func getRecentAvatars() throws -> [AvatarModel]
    func getAuthId() throws -> String
    func getAllChats(userId: String) async throws -> [ChatModel]
}

extension CoreInteractor: ChatsInteractor { }

@Observable
@MainActor
class ChatsViewModel {
    let interactor: ChatsInteractor
    
    private(set) var chats: [ChatModel] = []
    private(set) var isLoadingChats: Bool = true
    private(set) var recentAvatars: [AvatarModel] = []
    
    var path: [NavigationPathOption] = []
    
    var currentUserId: String? {
        interactor.auth?.uid
    }
    
    init(interactor: ChatsInteractor) {
        self.interactor = interactor
    }

    func loadRecentAvatars() {
        interactor.trackEvent(event: Event.loadAvatarsStart)
        do {
            recentAvatars = try interactor.getRecentAvatars()
            interactor.trackEvent(event: Event.loadAvatarsSuccess)
        } catch {
            interactor.trackEvent(event: Event.loadAvatarsFail(error: error))
        }
    }
    
    func loadChats() async {
        interactor.trackEvent(event: Event.loadChatsStart)
        do {
            let uid = try interactor.getAuthId()
            chats = try await interactor.getAllChats(userId: uid) // .sorted(by: { $0.updatedAt > $1.updatedAt })
                .sortedByKeyPath(keyPath: \.updatedAt, order: .descending)
            interactor.trackEvent(event: Event.loadChatsSuccess)
        } catch {
            interactor.trackEvent(event: Event.loadChatsFail(error: error))
        }
        isLoadingChats = false
    }
    
    func onChatPressed(chat: ChatModel) {
        path.append(.chat(avatarId: chat.avatarId, chat: chat))
        interactor.trackEvent(event: Event.chatPressed(chat: chat))
    }
    
    func onAvatarPresser(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
        interactor.trackEvent(event: Event.avatarPressed(avatar: avatar))
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
