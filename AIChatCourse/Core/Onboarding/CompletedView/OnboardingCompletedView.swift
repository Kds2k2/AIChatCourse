//
//  OnboardingCompletedView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 31.12.2025.
//

import SwiftUI

struct OnboardingCompletedView: View {
    @State var viewModel: OnboardingCompletedViewModel
    var selectedColor: Color = .orange
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Setup complete!")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundStyle(selectedColor)
            
            Text("We've set up your profile and you're ready to get start chatting.")
                .font(.title)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .frame(maxHeight: .infinity)
        .safeAreaInset(edge: .bottom, content: {
            AsyncCallToActionButton(
                isLoading: viewModel.isCompletingProfileSetup,
                title: "Finish",
                action: {
                    viewModel.onFinishButtonPressed(selectedColor: selectedColor)
                }
            )
            .accessibilityIdentifier("FinishButton")
        })
        .padding(24)
        .toolbarVisibility(.hidden, for: .navigationBar)
        .screenAppearAnalytics(name: "OnboardingCompletedView")
        .showCustomAlert(alert: $viewModel.showAlert)
    }
}

#Preview {
    OnboardingCompletedView(
        viewModel: .init(
            interactor: CoreInteractor(
                container: DevPreview.shared.container
            )
        ),
        selectedColor: .mint
    )
    .previewEnvironment()
}
