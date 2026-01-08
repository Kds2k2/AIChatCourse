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
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
