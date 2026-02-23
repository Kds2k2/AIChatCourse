//
//  AppView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 30.12.2025.
//

import SwiftUI

struct AppView: View {
    @Environment(\.scenePhase) private var scenePhase
    
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    @Environment(PurchaseManager.self) private var purchaseManager
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
        .task {
            try? await Task.sleep(for: .seconds(2))
            await showATTPromptIfNeeded()
        }
        .onChange(of: scenePhase, { _, newValue in
            switch newValue {
            case .active:
                Task { await checkUserStatus() }
            case .inactive:
                break
            case .background:
                break
            default:
                break
            }
        })
        .onChange(of: appState.showTabBar) { _, showTabBar in
            if !showTabBar {
                Task {
                    await checkUserStatus()
                }
            }
        }
        .onAppear {
            KeyboardWarmup.warmupInBackground()
        }
    }
    
    // MARK: - Loading
    private func checkUserStatus() async {
        if let user = authManager.auth {
            logManager.trackEvent(event: Event.existingAuthStart)
            
            do {
                try await userManager.logIn(auth: user, isNewUser: false)
                try await purchaseManager.logIn(userId: user.uid,
                                                attributes: .init(
                                                    email: user.email,
                                                    firebaseAppInstanceId: FirebaseAnalyticsService.appInstanceId))
            } catch {
                logManager.trackEvent(event: Event.existingAuthFail(error: error))
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        } else {
            logManager.trackEvent(event: Event.anonAuthStart)
            do {
                let result = try await authManager.singInAnonymously()
                logManager.trackEvent(event: Event.anonAuthSuccess)
                
                try await userManager.logIn(auth: result.user, isNewUser: result.isNewUser)
                try await purchaseManager.logIn(userId: result.user.uid,
                                                attributes: .init(
                                                    email: nil,
                                                    firebaseAppInstanceId: FirebaseAnalyticsService.appInstanceId))
            } catch {
                logManager.trackEvent(event: Event.anonAuthFail(error: error))
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        }
    }
    
    private func showATTPromptIfNeeded() async {
        #if !DEBUG
        let status = await AppTrackingTransparencyHelper.requestTrackingAuthorization()
        logManager.trackEvent(event: Event.attStatus(dict: status.eventParameters))
        #endif
    }
    
    // MARK: - Logs
    enum Event: LoggableEvent {
        case existingAuthStart, existingAuthFail(error: Error)
        case anonAuthStart, anonAuthSuccess, anonAuthFail(error: Error)
        case attStatus(dict: [String: Any])
        
        var eventName: String {
            switch self {
            case .existingAuthStart: "AppView_ExistingAuth_Start"
            case .existingAuthFail: "AppView_ExistingAuth_Fail"
            case .anonAuthStart: "AppView_AnonAuth_Start"
            case .anonAuthSuccess: "AppView_AnonAuth_Success"
            case .anonAuthFail: "AppView_AnonAuth_Fail"
            case .attStatus: "AppView_ATTStatus"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .existingAuthFail(error: let error), .anonAuthFail(error: let error):
                return error.eventParameters
            case .attStatus(dict: let dict):
                return dict
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .existingAuthFail, .anonAuthFail:
                .severe
            default:
                .analytic
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
