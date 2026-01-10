//
//  AppView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 30.12.2025.
//

import SwiftUI

struct AppView: View {
    @Environment(AuthManager.self) private var authManager
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
    }
    
    private func checkUserStatus() async {
        if let user = authManager.auth {
            print("User already authenticated: \(user.uid)")
        } else {
            // User is not authenticated
            do {
                let result = try await authManager.singInAnonymously()
                // log in the app
                print("Sign in anonymous succes: \(result.user.uid), new: \(result.isNewUser)")
            } catch {
                print(error)
            }
        }
    }
}

// I think, useful for empty/not empty state.
#Preview("AppView - tabBar") {
    AppView(appState: AppState(showTabBar: true))
}
#Preview("AppView - onboarding") {
    AppView(appState: AppState(showTabBar: false))
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
