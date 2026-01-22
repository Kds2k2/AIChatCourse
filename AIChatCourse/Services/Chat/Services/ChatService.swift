//
//  ChatService.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 17.01.2026.
//

import SwiftUI

protocol ChatService: Sendable {
    func createNewChat(chat: ChatModel) async throws
    func addChatMessage(message: ChatMessageModel) async throws
    func getChat(userId: String, avatarId: String) async throws -> ChatModel?
    func getAllChats(userId: String) async throws -> [ChatModel]
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel?
    func markChatMessageAsSeen(chatId: String, messageId: String, userId: String) async throws
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], Error>
    func deleteChat(chatId: String) async throws
    func deleteAllChatsForUser(userId: String) async throws
    func reportChat(report: ChatReportModel) async throws
}
