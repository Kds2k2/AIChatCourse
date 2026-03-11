//
//  CoreInteractor.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 06.03.2026.
//

import SwiftUI

@MainActor
struct CoreInteractor {
    
    private let authManager: AuthManager
    private let userManager: UserManager
    private let aiManager: AIManager
    private let avatarManager: AvatarManager
    private let chatManager: ChatManager
    private let logManager: LogManager
    private let pushManager: PushManager
    private let abTestManager: ABTestManager
    private let purchaseManager: PurchaseManager
    
    init(container: DependencyContainer) {
        self.authManager = container.resolve(AuthManager.self)!
        self.userManager = container.resolve(UserManager.self)!
        self.aiManager = container.resolve(AIManager.self)!
        self.avatarManager = container.resolve(AvatarManager.self)!
        self.chatManager = container.resolve(ChatManager.self)!
        self.logManager = container.resolve(LogManager.self)!
        self.pushManager = container.resolve(PushManager.self)!
        self.abTestManager = container.resolve(ABTestManager.self)!
        self.purchaseManager = container.resolve(PurchaseManager.self)!
    }
}

// MARK: - Auth Manager
extension CoreInteractor {
    var auth: UserAuthInfo? {
        authManager.auth
    }
    
    func getAuthId() throws -> String {
        try authManager.getAuthId()
    }
    
    func singInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await authManager.singInAnonymously()
    }
    
    func signInWithApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await authManager.signInWithApple()
    }
    
    func signInWithEmailAndPassword(email: String, password: String) async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await authManager.signInWithEmailAndPassword(email: email, password: password)
    }
    
    func signUpWithEmailAndPassword(email: String, password: String) async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await authManager.signUpWithEmailAndPassword(email: email, password: password)
    }
}

// MARK: - User Manager
extension CoreInteractor {
    var currentUser: UserModel? {
        userManager.currentUser
    }
    
    func markOnboardingCompletedForCurrentUser(profileColorHex: String) async throws {
        try await userManager.markOnboardingCompletedForCurrentUser(profileColorHex: profileColorHex)
    }
}

// MARK: - AI Manager
extension CoreInteractor {
    func generateImage(input: String) async throws -> UIImage {
        try await aiManager.generateImage(input: input)
    }
    
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        try await aiManager.generateText(chats: chats)
    }
}

// MARK: - Avatar Manager
extension CoreInteractor {
    var avatars: AvatarModel? {
        avatarManager.avatars
    }
    
    func addRecentAvatar(avatar: AvatarModel) async throws {
        try await avatarManager.addRecentAvatar(avatar: avatar)
    }
    
    func getRecentAvatars() throws -> [AvatarModel] {
        try avatarManager.getRecentAvatars()
    }
    
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        try await avatarManager.createAvatar(avatar: avatar, image: image)
    }
    
    func getAvatar(id: String) async throws -> AvatarModel {
        try await avatarManager.getAvatar(id: id)
    }
    
    func getFeaturedAvatars() async throws -> [AvatarModel] {
        try await avatarManager.getFeaturedAvatars()
    }
    
    func getPopularAvatars() async throws -> [AvatarModel] {
        try await avatarManager.getPopularAvatars()
    }
    
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        try await avatarManager.getAvatarsForCategory(category: category)
    }
    
    func removeAuthorIdFromAvatar(avatarId: String) async throws {
        try await avatarManager.removeAuthorIdFromAvatar(avatarId: avatarId)
    }
    
    func getAvatarsForUser(userId: String) async throws -> [AvatarModel] {
        try await avatarManager.getAvatarsForUser(userId: userId)
    }
}

// MARK: - Chat Manager
extension CoreInteractor {
    
    func createNewChat(chat: ChatModel) async throws {
        try await chatManager.createNewChat(chat: chat)
    }
    
    func getChat(userId: String, avatarId: String) async throws -> ChatModel? {
        try await chatManager.getChat(userId: userId, avatarId: avatarId)
    }
    
    func getAllChats(userId: String) async throws -> [ChatModel] {
        try await chatManager.getAllChats(userId: userId)
    }
    
    func addChatMessage(message: ChatMessageModel) async throws {
        try await chatManager.addChatMessage(message: message)
    }
    
    func markChatMessageAsSeen(chatId: String, messageId: String, userId: String) async throws {
        try await chatManager.markChatMessageAsSeen(chatId: chatId, messageId: messageId, userId: userId)
    }
    
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel? {
        try await chatManager.getLastChatMessage(chatId: chatId)
    }
    
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], Error> {
        chatManager.streamChatMessages(chatId: chatId)
    }
                                                                    
    func deleteChat(chatId: String) async throws {
        try await chatManager.deleteChat(chatId: chatId)
    }
    
    func reportChat(chatId: String, userId: String) async throws {
        try await chatManager.reportChat(chatId: chatId, userId: userId)
    }
}

// MARK: - Log Manager
extension CoreInteractor {
    func identifyUser(userId: String, name: String?, email: String?) {
        logManager.identifyUser(userId: userId, name: name, email: email)
    }
    
    func addUserProperties(dict: [String: Any], isHighPriority: Bool) {
        logManager.addUserProperties(dict: dict, isHighPriority: isHighPriority)
    }
    
    func trackEvent(eventName: String, parameners: [String: Any]? = nil, type: LogType = .analytic) {
        let event = AnyLoggableEvent(
            eventName: eventName,
            parameters: parameners,
            type: type
        )
        logManager.trackEvent(event: event)
    }
    
    func trackEvent(event: AnyLoggableEvent) {
        logManager.trackEvent(event: event)
    }
    
    func trackEvent(event: LoggableEvent) {
        logManager.trackEvent(event: event)
    }
    
    func trackScreenEvent(event: LoggableEvent) {
        logManager.trackScreenEvent(event: event)
    }
}

// MARK: - Push Manager
extension CoreInteractor {
    func requestAuthorization() async throws -> Bool {
        try await pushManager.requestAuthorization()
    }
    
    func canRequestAuthorization() async -> Bool {
        await pushManager.canRequestAuthorization()
    }
    
    func schedulePushNotificationForTheNextWeek() {
        pushManager.schedulePushNotificationForTheNextWeek()
    }
}

// MARK: - ABTest Manager
extension CoreInteractor {
    
    var activeTests: ActiveABTests {
        abTestManager.activeTests
    }
    
    var categoryRowTest: CategoryRowTestOption {
        abTestManager.activeTests.categoryRowTest
    }
    
    var createAccountTest: Bool {
        abTestManager.activeTests.createAccountTest
    }
    
    var onboardingCommunityTest: Bool {
        abTestManager.activeTests.onboardingCommunityTest
    }
    
    var paywallTest: PaywallTestOption {
        abTestManager.activeTests.paywallTest
    }
    
    func override(updateTests: ActiveABTests) throws {
        try abTestManager.override(updateTests: updateTests)
    }
}

// MARK: - Purchase Manager
extension CoreInteractor {
    var entitlements: [PurchasedEntitlement] {
        purchaseManager.entitlements
    }
    
    var isPremium: Bool {
        entitlements.hasActiveEntitlement
    }
    
    func getProducts(productIds: [String]) async throws -> [AnyProduct] {
        try await purchaseManager.getProducts(productIds: productIds)
    }
    
    func restorePurchase() async throws -> [PurchasedEntitlement] {
        try await purchaseManager.restorePurchase()
    }
    
    func purchaseProduct(productId: String) async throws -> [PurchasedEntitlement] {
        try await purchaseManager.purchaseProduct(productId: productId)
    }
    
    func updateProfileAttributes(attributes: PurchaseProfileAttributes) async throws {
        try await purchaseManager.updateProfileAttributes(attributes: attributes)
    }
    
}

// MARK: - Shared
extension CoreInteractor {
    func signOut() async throws {
        try authManager.signOut()
        try await purchaseManager.logOut()
        userManager.signOut()
    }
    
    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws {
        try await userManager.logIn(auth: auth, isNewUser: isNewUser)
        try await purchaseManager.logIn(userId: auth.uid,
                                        attributes: .init(
                                            email: auth.email,
                                            firebaseAppInstanceId: FirebaseAnalyticsService.appInstanceId,
                                            mixpanelDistinctId: MixpanelService.distinctId))
    }
    
    func deleteAccount(userId: String) async throws {
        try await chatManager.deleteAllChatsForUser(userId: userId)
        try await avatarManager.removeAuthorIdFromAllUserAvatars(userId: userId)
        try await userManager.deleleCurrentUser()
        try await authManager.deleteAccount()
        try await purchaseManager.logOut()
        logManager.deleteUserProfile()
    }
}
