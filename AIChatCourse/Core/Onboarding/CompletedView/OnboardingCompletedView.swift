//
//  OnboardingCompletedView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 31.12.2025.
//

import SwiftUI

struct OnboardingCompletedView: View {
    
    @Environment(AppState.self) private var root
    @Environment(UserManager.self) private var userManager
    
    @State private var isCompletingProfileSetup: Bool = false
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
                isLoading: isCompletingProfileSetup,
                title: "Finish",
                action: onFinishButtonPressed
            )
        })
        .padding(24)
        .toolbarVisibility(.hidden, for: .navigationBar)
    }
    
    func onFinishButtonPressed() {
        isCompletingProfileSetup = true

        Task {
            let hex = selectedColor.toHex()
            try await userManager.markOnboardingCompletedForCurrentUser(profileColorHex: hex)
            
            // dismiss screen
            isCompletingProfileSetup = false
            root.updateViewState(showTabBarView: true)
        }
    }
}

#Preview {
    OnboardingCompletedView(selectedColor: .mint)
        .environment(UserManager(service: MockUserService()))
        .environment(AppState())
}
