//
//  OnboardingCommunityView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 19.02.2026.
//

import SwiftUI

struct OnboardingCommunityView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: OnboardingCommunityViewModel
    @Binding var path: [OnboardingPathOption]
    
    var body: some View {
        VStack {
            VStack(spacing: 40) {
                ImageLoaderView()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                
                Group {
                    Text("Join our community with over ")
                    +
                    Text("1000+ ")
                        .foregroundStyle(.accent)
                        .fontWeight(.semibold)
                    +
                    Text("custom avatars! \n\nAsk them questions or have a casual conversation!")
                }
                .baselineOffset(6)
                .minimumScaleFactor(0.5)
                .padding(24)
            }
            .frame(maxHeight: .infinity)

            Text("Continue")
                .callToActionButton()
                .accessibilityIdentifier("OnboardingCommunityContinueButton")
                .anyButton(.press) {
                    viewModel.onContinuePressed(path: $path)
                }
        }
        .font(.title3)
        .padding(24)
        .toolbarVisibility(.hidden, for: .navigationBar)
        .screenAppearAnalytics(name: "OnboardingCommunityView")
    }
}

#Preview {
    NavigationStack {
        OnboardingCommunityView(viewModel: .init(interactor: CoreInteractor(container: DevPreview.shared.container)), path: .constant([]))
    }
    .previewEnvironment()
}
