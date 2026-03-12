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
    
    var body: some View {
        AppViewBuilder(
            showTabBar: viewModel.showTabBar,
            tabbarView: {
                TabBarView()
            },
            onboardingView: {
                WelcomeView(viewModel: WelcomeViewModel(interactor: CoreInteractor(container: container)))
            }
        )
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
        .onChange(of: viewModel.showTabBar) { _, showTabBar in
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
    container.register(AppState.self, service: AppState(showTabBar: true))
    
    return AppView(
        viewModel: AppViewModel(interactor: CoreInteractor(container: container))
    )
    .previewEnvironment()
}
#Preview("AppView - onboarding") {
    let container = DevPreview.shared.container
    container.register(UserManager.self, service: UserManager(services: MockUserServices(user: nil)))
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: nil)))
    container.register(AppState.self, service: AppState(showTabBar: false))
    
    return AppView(
        viewModel: AppViewModel(interactor: CoreInteractor(container: container))
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
