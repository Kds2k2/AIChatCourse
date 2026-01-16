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
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    var dependencies: AppDependencies!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        dependencies = AppDependencies()
        
        return true
    }
}

@MainActor
struct AppDependencies {
    
    let authManager: AuthManager
    let userManager: UserManager
    let aiManager: AIManager
    let avatarManager: AvatarManager
    let chatManager: ChatManager
    
    init() {
        authManager = AuthManager(service: FirebaseAuthService())
        userManager = UserManager(services: ProductionUserServices())
        aiManager = AIManager(service: OpenAIService())
        avatarManager = AvatarManager(remote: FirebaseAvatarService(),
                                      local: SwiftDataLocalPersistence())
        chatManager = ChatManager(service: FirebaseChatService())
    }
}

extension View {
    func previewEnvironment(isSignedIn: Bool = true) -> some View {
        self
            .environment(AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil)))
            .environment(UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil)))
            .environment(AIManager(service: MockAIService()))
            .environment(AvatarManager(remote: MockAvatarService()))
            .environment(ChatManager(service: MockChatService()))
            .environment(AppState())
    }
}
