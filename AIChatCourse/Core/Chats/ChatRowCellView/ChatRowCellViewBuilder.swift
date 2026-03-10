//
//  ChatRowCellViewBuilder.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 03.01.2026.
//

import SwiftUI

struct ChatRowCellViewBuilder: View {

    @State var viewModel: ChatRowCellViewModel
    var chat: ChatModel = .mock // Get from parent view
    
    var body: some View {
        ChatRowCellView(
            imageName: viewModel.avatar?.profileImageName,
            headline: viewModel.isLoading ? "xxxx xxxx" : viewModel.avatar?.name,
            subheadline: viewModel.subheadline,
            hasNewChat: viewModel.isLoading ? false : viewModel.hasNewChat
        )
        .redacted(reason: viewModel.isLoading ? .placeholder : [])
        .task {
            await viewModel.loadAvatar(chat: chat)
        }
        .task {
            await viewModel.loadLastChatMessage(chat: chat)
        }
    }
}

@MainActor
struct AnyChatRowCellInteractor: ChatRowCellInteractor {
    let anyAuth: UserAuthInfo?
    let anyGetAvatar: (String) async throws -> AvatarModel
    let anyGetLastChatMessage: (String) async throws -> ChatMessageModel?
    
    init(
        auth: UserAuthInfo?,
        getAvatar: @escaping (String) async throws -> AvatarModel,
        getLastChatMessage: @escaping (String) async throws -> ChatMessageModel?
    ) {
        self.anyAuth = auth
        self.anyGetAvatar = getAvatar
        self.anyGetLastChatMessage = getLastChatMessage
    }
    
    init(interactor: ChatRowCellInteractor) {
        self.anyAuth = interactor.auth
        self.anyGetAvatar = interactor.getAvatar
        self.anyGetLastChatMessage = interactor.getLastChatMessage
    }
    
    var auth: UserAuthInfo? { anyAuth }
    
    func getAvatar(id: String) async throws -> AvatarModel {
        try await anyGetAvatar(id)
    }
    
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel? {
        try await anyGetLastChatMessage(chatId)
    }
}

#Preview {
    VStack {
// OLD
//        ChatRowCellViewBuilder(chat: .mock, getAvatar: {
//            try? await Task.sleep(for: .seconds(5))
//            return .mock
//        }, getLastChatMessage: {
//            try? await Task.sleep(for: .seconds(5))
//            return .mock
//        })
        
        let container = DevPreview.shared.container
        ChatRowCellViewBuilder(viewModel: ChatRowCellViewModel(interactor: CoreInteractor(container: container)), chat: .mock)
        
        ChatRowCellViewBuilder(
            viewModel: ChatRowCellViewModel(
                interactor: AnyChatRowCellInteractor(
                    auth: UserAuthInfo.mock(),
                    getAvatar: { _ in
                        try? await Task.sleep(for: .seconds(10))
                        return .mock
                    },
                    getLastChatMessage: { _ in
                        try? await Task.sleep(for: .seconds(10))
                        return .mock
                    }
                )
            ),
            chat: .mock
        )
        
        ChatRowCellViewBuilder(
            viewModel: ChatRowCellViewModel(
                interactor: AnyChatRowCellInteractor(
                    auth: UserAuthInfo.mock(),
                    getAvatar: { _ in
                        throw URLError(.badServerResponse)
                    },
                    getLastChatMessage: { _ in
                        throw URLError(.badServerResponse)
                    }
                )
            ),
            chat: .mock
        )
    }
    .previewEnvironment()
}
