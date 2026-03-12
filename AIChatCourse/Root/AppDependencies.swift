//
//  AppDependencies.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 12.03.2026.
//

import SwiftUI

@MainActor
struct AppDependencies {
    
    let container: DependencyContainer
    let authManager: AuthManager
    let userManager: UserManager
    let aiManager: AIManager
    let avatarManager: AvatarManager
    let chatManager: ChatManager
    let logManager: LogManager
    let pushManager: PushManager
    let abTestManager: ABTestManager
    let purchaseManager: PurchaseManager
    let appState: AppState
    
    // swiftlint:disable function_body_length
    init(_ config: BuildConfiguration) {
        switch config {
        case .mock(isSignedIn: let isSignedIn):
            logManager = LogManager(services: [
                ConsoleService(printParameters: false)
            ])
            authManager = AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil), logManager: logManager)
            userManager = UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil), logManager: logManager)
            aiManager = AIManager(service: MockAIService())
            avatarManager = AvatarManager(remote: MockAvatarService(),
                                          local: MockLocalAvatarPersistence())
            chatManager = ChatManager(service: MockChatService())
            let abTestService = MockABTestService(
                onboardingCommunityTest: LaunchArgumentOptions.onboardingCommunity.value,
                paywallTest: .custom
            )
            abTestManager = ABTestManager(service: abTestService, logManager: logManager)
            purchaseManager = PurchaseManager(service: MockPurchaseService())
            appState = AppState(showTabBar: isSignedIn)
        case .dev:
            logManager = LogManager(services: [
                ConsoleService(printParameters: true),
                FirebaseAnalyticsService(),
                FirebaseCrashlyticsService(),
                MixpanelService(token: AppKeys.mixpanel)
            ])
            authManager = AuthManager(service: FirebaseAuthService(), logManager: logManager)
            userManager = UserManager(services: ProductionUserServices(), logManager: logManager)
            aiManager = AIManager(service: OpenAIService())
            avatarManager = AvatarManager(remote: FirebaseAvatarService(),
                                          local: SwiftDataLocalPersistence())
            chatManager = ChatManager(service: FirebaseChatService())
            abTestManager = ABTestManager(service: LocalABTestService(), logManager: logManager)
            purchaseManager = PurchaseManager(
                service: RevenueCatPurchaseService(apiKey: AppKeys.revenueCatDev), // StoreKitPurchaseService(),
                logManager: logManager
            )
            appState = AppState()
        case .prod:
            logManager = LogManager(services: [
                FirebaseAnalyticsService(),
                FirebaseCrashlyticsService(),
                MixpanelService(token: AppKeys.mixpanel)
            ])
            authManager = AuthManager(service: FirebaseAuthService(), logManager: logManager)
            userManager = UserManager(services: ProductionUserServices(), logManager: logManager)
            aiManager = AIManager(service: OpenAIService())
            avatarManager = AvatarManager(remote: FirebaseAvatarService(),
                                          local: SwiftDataLocalPersistence())
            chatManager = ChatManager(service: FirebaseChatService())
            abTestManager = ABTestManager(service: FirebaseABTestService(), logManager: logManager)
            purchaseManager = PurchaseManager(
                service: RevenueCatPurchaseService(apiKey: AppKeys.revenueCat), // StoreKitPurchaseService(),
                logManager: logManager
            )
            appState = AppState()
        }
        
        pushManager = PushManager(logManager: logManager)
        
        let container = DependencyContainer()
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(AIManager.self, service: aiManager)
        container.register(AvatarManager.self, service: avatarManager)
        container.register(ChatManager.self, service: chatManager)
        container.register(LogManager.self, service: logManager)
        container.register(PushManager.self, service: pushManager)
        container.register(ABTestManager.self, service: abTestManager)
        container.register(PurchaseManager.self, service: purchaseManager)
        container.register(AppState.self, service: appState)
        self.container = container
    }
    // swiftlint:enable function_body_length
}

extension View {
    func previewEnvironment(isSignedIn: Bool = true) -> some View {
        self
            .environment(LogManager(services: []))
            .environment(DevPreview.shared.container)
    }
}

@MainActor
class DevPreview {
    static let shared = DevPreview()
    
    var container: DependencyContainer {
        let container = DependencyContainer()
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(AIManager.self, service: aiManager)
        container.register(AvatarManager.self, service: avatarManager)
        container.register(ChatManager.self, service: chatManager)
        container.register(LogManager.self, service: logManager)
        container.register(PushManager.self, service: pushManager)
        container.register(ABTestManager.self, service: abTestManager)
        container.register(PurchaseManager.self, service: purchaseManager)
        container.register(AppState.self, service: appState)
        return container
    }
    
    let authManager: AuthManager
    let userManager: UserManager
    let aiManager: AIManager
    let avatarManager: AvatarManager
    let chatManager: ChatManager
    let logManager: LogManager
    let pushManager: PushManager
    let abTestManager: ABTestManager
    let purchaseManager: PurchaseManager
    let appState: AppState
    
    init(isSignedIn: Bool = true) {
        self.authManager = AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil))
        self.userManager = UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil))
        self.aiManager = AIManager(service: MockAIService())
        self.avatarManager = AvatarManager(remote: MockAvatarService(), local: MockLocalAvatarPersistence())
        self.chatManager = ChatManager(service: MockChatService())
        self.logManager = LogManager(services: [])
        self.pushManager = PushManager()
        self.abTestManager = ABTestManager(service: MockABTestService())
        self.purchaseManager = PurchaseManager(service: MockPurchaseService())
        self.appState = AppState()
    }
}
