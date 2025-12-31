//
//  OnboardingCompletedView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 31.12.2025.
//

import SwiftUI

struct OnboardingCompletedView: View {
    
    @Environment(AppState.self) private var root
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Onboarding Completed!")
                    .frame(maxHeight: .infinity)

                Button {
                    onFinishButtonPressed()
                } label: {
                    Text("Finish")
                        .callToActionButton()
                }
            }
            .padding(16)
        }
    }
    
    func onFinishButtonPressed() {
        root.updateViewState(showTabBarView: true)
    }
}

#Preview {
    OnboardingCompletedView()
        .environment(AppState())
}
