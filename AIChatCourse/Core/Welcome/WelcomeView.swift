//
//  WelcomeView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 31.12.2025.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(AppState.self) private var root
    @State var viewModel: WelcomeViewModel
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            VStack(spacing: 8) {
                ImageLoaderView(urlString: viewModel.imageName)
                    .ignoresSafeArea()
                
                titleSection
                    .padding(.top, 24)
                
                ctaButtons
                    .padding(16)
                
                policyLinks
            }
            .navigationDestinationForOnboardingModule(path: $viewModel.path)
        }
        .screenAppearAnalytics(name: "WelcomeView")
        .showCustomAlert(type: .confirmationDialog, alert: $viewModel.showCreateAccountMenu)
        .sheet(isPresented: $viewModel.showAppleProvider) {
            CreateAccountWithAppleView(viewModel: CreateAccountWithAppleViewModel(interactor: CoreInteractor(container: container))) { isNewUser in
                viewModel.handleDidSignIn(isNewUser: isNewUser, onOldUser: {
                    root.updateViewState(showTabBarView: true)
                })
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $viewModel.showEmailProvider) {
            SignInWithEmailAndPasswordView(viewModel: SignInWithEmailAndPasswordViewModel(interactor: CoreInteractor(container: container))) { isNewUser in
                viewModel.handleDidSignIn(isNewUser: isNewUser, onOldUser: {
                    root.updateViewState(showTabBarView: true)
                })
            }
        }
    }

    // MARK: - Views
    private var titleSection: some View {
        VStack {
            Text("AI Chat")
                .font(.largeTitle)
                .fontWeight(.semibold)
            
            Text("Swift @ DimaKryzhanovsky")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private var ctaButtons: some View {
        VStack(spacing: 8) {
            Text("Get Started!")
                .callToActionButton()
                .anyButton(.press) {
                    viewModel.onGetStartedPressed()
                }
                .accessibilityIdentifier("StartButton")
            
            Text("Already have an account? Sign in!")
                .underline()
                .font(.body)
                .padding(8)
                .onTapGesture {
                    viewModel.onSignInPressed()
                }
        }
    }
    
    private var policyLinks: some View {
        HStack(spacing: 8) {
            Link(destination: URL(string: Constants.termosOfServiceURL)!) {
                Text("Terms of Service")
            }
            
            Circle()
                .fill(.accent)
                .frame(width: 4, height: 4)
            
            Link(destination: URL(string: Constants.privacyPolicyURL)!) {
                Text("Privacy Policy")
            }
        }
    }
}

#Preview {
    NavigationStack {
        WelcomeView(viewModel: WelcomeViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)))
            .previewEnvironment()
    }
}
