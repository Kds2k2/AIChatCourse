//
//  AIChatCourseApp.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 29.12.2025.
//

import SwiftUI
import Firebase
import FirebaseInstallations
import FirebaseCore

@main
struct AppEntryPoint {
    static func main() {
        if AppInfo.isUnitTesting {
            TestingApp.main()
        } else {
            AIChatCourseApp.main()
        }
    }
}

struct TestingApp: App {
    var body: some Scene {
        WindowGroup {
            Text("Testing!")
        }
    }
}

struct AIChatCourseApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            Group {
                if AppInfo.isUITesting {
                    AppViewForUITesting()
                } else {
                    AppView()
                }
            }
            .environment(delegate.dependencies.container)
            .environment(delegate.dependencies.authManager)
            .environment(delegate.dependencies.userManager)
            .environment(delegate.dependencies.aiManager)
            .environment(delegate.dependencies.avatarManager)
            .environment(delegate.dependencies.chatManager)
            .environment(delegate.dependencies.logManager)
            .environment(delegate.dependencies.pushManager)
            .environment(delegate.dependencies.abTestManager)
            .environment(delegate.dependencies.purchaseManager)
        }
    }
}

struct AppViewForUITesting: View {
    var body: some View {
        if LaunchArgumentOptions.screenCreateAvatar.value {
            // CreateAvatarView()
            // TODO: FIX ME!
        } else {
            AppView()
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
        
        var config: BuildConfiguration
        
        #if MOCK
        config = .mock(isSignedIn: true)
        #elseif DEV
        config = .dev
        #else
        config = .prod
        #endif
        
        if AppInfo.isUITesting {
            let signIn = LaunchArgumentOptions.signIn.value
            UserDefaults.showTabBarView = signIn
            config = .mock(isSignedIn: signIn)
            print("MOOOOCK")
        }
        
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

@Observable
@MainActor
class DependencyContainer {
    private var services: [String: Any] = [:]
    
    func register<T>(_ type: T.Type, service: T) {
        let key = "\(type)"
        services[key] = service
    }
    
    func register<T>(_ type: T.Type, service: () -> T) {
        let key = "\(type)"
        services[key] = service()
    }
    
    func resolve<T>(_ type: T.Type) -> T? {
        let key = "\(type)"
        return services[key] as? T
    }
}

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
        self.container = container
    }
    // swiftlint:enable function_body_length
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
            .environment(PurchaseManager(service: MockPurchaseService()))
            .environment(AppState())
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
    }
}
