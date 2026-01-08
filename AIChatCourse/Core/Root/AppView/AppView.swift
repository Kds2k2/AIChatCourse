//
//  AppView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 30.12.2025.
//

import SwiftUI

struct AppView: View {
    @Environment(\.authService) private var authService
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
    }
    
    private func checkUserStatus() async {
        if let user = authService.getAuthenticatedUser() {
            // User is authenticated
            print("User already authenticated: \(user.uid)")
        } else {
            // User is not authenticated
            do {
                let result = try await authService.singInAnonymously()
                // log in t app
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
