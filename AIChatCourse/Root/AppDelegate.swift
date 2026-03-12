//
//  AppDelegate.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 12.03.2026.
//

import SwiftUI
import Firebase
import FirebaseInstallations
import FirebaseCore

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
            config = .mock(isSignedIn: signIn)
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
