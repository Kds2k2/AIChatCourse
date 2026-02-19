//
//  AIChatCourseApp.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 29.12.2025.
//

import SwiftUI
import Firebase

@main
struct AIChatCourseApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(delegate.dependencies.authManager)
                .environment(delegate.dependencies.userManager)
                .environment(delegate.dependencies.aiManager)
                .environment(delegate.dependencies.avatarManager)
                .environment(delegate.dependencies.chatManager)
                .environment(delegate.dependencies.logManager)
                .environment(delegate.dependencies.pushManager)
                .environment(delegate.dependencies.abTestManager)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    var dependencies: AppDependencies!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        // MOCK - mock dependencies
        // DEVELOPMENT - production dependencies + some extra dev tool
        // PRODUCTION - production dependencies
        // Also could: Staging, Beta, Alpha, ...
        
        let config: BuildConfiguration
        
        #if MOCK
        config = .mock(isSignedIn: true)
        #elseif DEV
        config = .dev
        #else
        config = .prod
        #endif
        
        config.configure()
        dependencies = AppDependencies(config)
        return true
    }
}

enum BuildConfiguration {
    case mock(isSignedIn: Bool), dev, prod
    
    func configure() {
        switch self {
        case .mock:
            break
        case .dev:
            let plist = Bundle.main.path(forResource: "GoogleService-Info-Dev", ofType: "plist")!
            let options = FirebaseOptions(contentsOfFile: plist)!
            FirebaseApp.configure(options: options)
        case .prod:
            let plist = Bundle.main.path(forResource: "GoogleService-Info-Prod", ofType: "plist")!
            let options = FirebaseOptions(contentsOfFile: plist)!
            FirebaseApp.configure(options: options)
        }
    }
}

@MainActor
struct AppDependencies {
    
    let authManager: AuthManager
    let userManager: UserManager
    let aiManager: AIManager
    let avatarManager: AvatarManager
    let chatManager: ChatManager
    let logManager: LogManager
    let pushManager: PushManager
    let abTestManager: ABTestManager
    
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
            abTestManager = ABTestManager(service: MockABTestService(), logManager: logManager)
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
            abTestManager = ABTestManager(service: MockABTestService(), logManager: logManager)
        }
        
        pushManager = PushManager(logManager: logManager)
    }
}

extension View {
    func previewEnvironment(isSignedIn: Bool = true) -> some View {
        self
            .environment(AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil)))
            .environment(UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil)))
            .environment(AIManager(service: MockAIService()))
            .environment(AvatarManager(remote: MockAvatarService(), local: MockLocalAvatarPersistence()))
            .environment(ChatManager(service: MockChatService()))
            .environment(LogManager(services: []))
            .environment(PushManager())
            .environment(ABTestManager(service: MockABTestService()))
            .environment(AppState())
    }
}
