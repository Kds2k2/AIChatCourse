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
                .environment(delegate.authManager)
                .environment(delegate.userManager)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    var authManager: AuthManager!
    var userManager: UserManager!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        authManager = AuthManager(service: FirebaseAuthService())
        userManager = UserManager(services: ProductionUserServices())
        
        return true
    }
}
