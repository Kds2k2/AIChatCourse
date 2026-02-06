//
//  AppView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 30.12.2025.
//

import SwiftUI

struct AppView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    @State var appState: AppState = AppState()

    var body: some View {
        AppViewBuilder(
            showTabBar: appState.showTabBar,
            tabbarView: {
                TabBarView()
            },
            onboardingView: {
                WelcomeView()
            }
        )
        .environment(appState)
        .task {
            await checkUserStatus()
        }
        .onChange(of: appState.showTabBar) { _, showTabBar in
            if !showTabBar {
                Task {
                    await checkUserStatus()
                }
            }
        }
        .onAppear {
            logManager.identifyUser(userId: "123", name: "Dima", email: "dk@gm.com")
            logManager.addUserProperties(dict: UserModel.mock.eventParameters, isHighPriority: true)
            
            logManager.trackEvent(event: Event.alpha)
            logManager.trackEvent(event: Event.beta)
            logManager.trackEvent(event: Event.gamma)
            logManager.trackEvent(event: Event.delta)
            
            let event = AnyLoggableEvent(
                eventName: "MyNewEvent",
                parameters: UserModel.mock.eventParameters,
                type: .analytic
            )
            logManager.trackEvent(event: event)
            
            logManager.trackEvent(eventName: "AnotherEvent")
        }
        .onAppear {
            KeyboardWarmup.warmupInBackground()
        }
    }
    
    enum Event: LoggableEvent {
        case alpha, beta, gamma, delta
        
        var eventName: String {
            switch self {
            case .alpha:
                "Event_Alpha"
            case .beta:
                "Event_Beta"
            case .gamma:
                "Event_Gamma"
            case .delta:
                "Event_Delta"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .alpha, .beta:
                return ["aaa": true, "bbb": 123]
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .alpha:
                    .info
            case .beta:
                    .analytic
            case .gamma:
                    .waring
            case .delta:
                    .severe
            }
        }
    }
    
    private func checkUserStatus() async {
        if let user = authManager.auth {
            print("User already authenticated: \(user.uid)")
            
            do {
                try await userManager.logIn(auth: user, isNewUser: false)
            } catch {
                print("Failed to log in to auth for existing user: \(error)")
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        } else {
            do {
                let result = try await authManager.singInAnonymously()
                print("Sign in anonymous succes: \(result.user.uid), new: \(result.isNewUser)")
                
                try await userManager.logIn(auth: result.user, isNewUser: result.isNewUser)
            } catch {
                print("Failed to sign in anonymously and log in: \(error)")
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        }
    }
}

// I think, useful for empty/not empty state.
#Preview("AppView - tabBar") {
    AppView(appState: AppState(showTabBar: true))
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .environment(AuthManager(service: MockAuthService(user: .mock())))
}
#Preview("AppView - onboarding") {
    AppView(appState: AppState(showTabBar: false))
        .environment(UserManager(services: MockUserServices(user: nil)))
        .environment(AuthManager(service: MockAuthService(user: nil)))
}

// VARIANT 2
//
// ZStack {
//    Color.red.ignoresSafeArea()
//    Text("tabBar")
// }
// .onAppear(perform: {
//    // Check if user not signed.
//    showOnboardingView = true
// })
// .fullScreenCover(isPresented: $showOnboardingView) {
//    ZStack {
//        Color.blue.ignoresSafeArea()
//        Text("onboarding")
//    }
// }
