//
//  ChatRowCellViewModel.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 10.03.2026.
//

import SwiftUI

@MainActor
protocol ChatRowCellInteractor {
    var auth: UserAuthInfo? { get }
    
    func getAvatar(id: String) async throws -> AvatarModel
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel?
}

extension CoreInteractor: ChatRowCellInteractor { }

@Observable
@MainActor
class ChatRowCellViewModel {
    let interactor: ChatRowCellInteractor
    
    private(set) var avatar: AvatarModel?
    private(set) var didLoadAvatar: Bool = false
    private(set) var lastChatMessage: ChatMessageModel?
    private(set) var didLoadChatMessage: Bool = false
    
    var currentUserId: String? {
        interactor.auth?.uid
    }
    
    var isLoading: Bool {
        (didLoadAvatar && didLoadChatMessage) ? false : true
    }
    
    var subheadline: String? {
        if isLoading {
            return "xxxx xxxx xxxx xxxx"
        }
        
        if avatar == nil && lastChatMessage == nil {
            return "Error"
        }
        
        return lastChatMessage?.content?.message
    }
    
    var hasNewChat: Bool {
        guard let lastChatMessage, let currentUserId else { return false }
        return !lastChatMessage.hasBeenSeenBy(userId: currentUserId)
    }
    
    init(interactor: ChatRowCellInteractor) {
        self.interactor = interactor
    }
    
    func loadAvatar(chat: ChatModel) async {
        avatar = try? await interactor.getAvatar(id: chat.avatarId)
        didLoadAvatar = true
    }
    
    func loadLastChatMessage(chat: ChatModel) async {
        lastChatMessage = try? await interactor.getLastChatMessage(chatId: chat.id)
        didLoadChatMessage = true
    }
}
