//
//  AppView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 30.12.2025.
//

import SwiftUI

struct AppView: View {
    
    @Environment(DependencyContainer.self) private var container
    @Environment(\.scenePhase) private var scenePhase
    @State var viewModel: AppViewModel
    @State var appState: AppState = AppState()
    
    var body: some View {
        AppViewBuilder(
            showTabBar: appState.showTabBar,
            tabbarView: {
                TabBarView()
            },
            onboardingView: {
                WelcomeView(viewModel: WelcomeViewModel(interactor: CoreInteractor(container: container)))
            }
        )
        .environment(appState)
        .task {
            await viewModel.checkUserStatus()
        }
        .task {
            try? await Task.sleep(for: .seconds(2))
            await viewModel.showATTPromptIfNeeded()
        }
        .onChange(of: scenePhase, { _, newValue in
            switch newValue {
            case .active:
                Task { await viewModel.checkUserStatus() }
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
                    await viewModel.checkUserStatus()
                }
            }
        }
        .onAppear {
            KeyboardWarmup.warmupInBackground()
        }
    }
}

// I think, useful for empty/not empty state.
#Preview("AppView - tabBar") {
    let container = DevPreview.shared.container
    
    return AppView(
        viewModel: AppViewModel(interactor: CoreInteractor(container: container)),
        appState: AppState(showTabBar: true)
    )
    .previewEnvironment()
}
#Preview("AppView - onboarding") {
    let container = DevPreview.shared.container
    container.register(UserManager.self, service: UserManager(services: MockUserServices(user: nil)))
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: nil)))
    
    return AppView(
        viewModel: AppViewModel(interactor: CoreInteractor(container: container)),
        appState: AppState(showTabBar: false)
    )
    .previewEnvironment()
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
