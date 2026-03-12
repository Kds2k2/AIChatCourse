//
//  OnboardingIntroView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 01.01.2026.
//

import SwiftUI

struct OnboardingIntroView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: OnboardingIntroViewModel
    @Binding var path: [OnboardingPathOption]
    
    var body: some View {
        VStack {
            Group {
                Text("Make your own ")
                +
                Text("avatars ")
                    .foregroundStyle(.accent)
                    .fontWeight(.semibold)
                +
                Text("and chat with them!\n\nHave ")
                +
                Text("real conversations ")
                    .foregroundStyle(.accent)
                    .fontWeight(.semibold)
                +
                Text("with AI generated responses.")
            }
            .baselineOffset(6)
            .frame(maxHeight: .infinity)
            .padding(24)

            Text("Continue")
                .callToActionButton()
                .accessibilityIdentifier("ContinueButton")
                .anyButton(.press) {
                    viewModel.onContinuePressed(path: $path)
                }
        }
        .font(.title3)
        .padding(24)
        .toolbarVisibility(.hidden, for: .navigationBar)
        .screenAppearAnalytics(name: "OnboardingIntroView")
    }
}

#Preview("Original") {
    let container = DevPreview.shared.container
    
    return NavigationStack {
        OnboardingIntroView(viewModel: OnboardingIntroViewModel(interactor: CoreInteractor(container: container)), path: .constant([]))
    }
    .previewEnvironment()
}

#Preview("Onboarding Community Test") {
    let container = DevPreview.shared.container
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(onboardingCommunityTest: true)))
    
    return NavigationStack {
        OnboardingIntroView(viewModel: OnboardingIntroViewModel(interactor: CoreInteractor(container: container)), path: .constant([]))
    }
    .previewEnvironment()
}
