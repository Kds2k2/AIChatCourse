//
//  WelcomeView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 31.12.2025.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(AppState.self) private var root
    @Environment(LogManager.self) private var logManager
    
    @State private var imageName: String = Constants.randomImage
    @State private var showCreateAccountMenu: AnyAppAlert?
    @State private var showAppleProvider: Bool = false
    @State private var showEmailProvider: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                ImageLoaderView(urlString: imageName)
                    .ignoresSafeArea()
                
                titleSection
                    .padding(.top, 24)
                
                ctaButtons
                    .padding(16)
                
                policyLinks
            }
        }
        .screenAppearAnalytics(name: "WelcomeView")
        .showCustomAlert(type: .confirmationDialog, alert: $showCreateAccountMenu)
        .sheet(isPresented: $showAppleProvider) {
            CreateAccountWithAppleView { isNewUser in
                handleDidSignIn(isNewUser: isNewUser)
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showEmailProvider) {
            SignInWithEmailAndPasswordView { isNewUser in
                handleDidSignIn(isNewUser: isNewUser)
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
            NavigationLink {
                OnboardingIntroView()
            } label: {
                Text("Get Started!")
                    .callToActionButton()
            }
            .accessibilityIdentifier("StartButton")
            
            Text("Already have an account? Sign in!")
                .underline()
                .font(.body)
                .padding(8)
                .onTapGesture {
                    onSignInPressed()
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
    
    // MARK: - Actions
    private func onSignInPressed() {
        showCreateAccountMenu = AnyAppAlert(
            title: "",
            subtitle: "Select provider",
            buttons: {
                AnyView(
                    Group {
                        Button("Apple", role: .destructive) {
                            showAppleProvider = true
                        }
                        Button("Email", role: .destructive) {
                            showEmailProvider = true
                        }
                    }
                )
            }
        )
    }

    private func handleDidSignIn(isNewUser: Bool) {
        if isNewUser {
            // Do nothing
        } else {
            Task {
                try? await Task.sleep(for: .seconds(0.5))
                root.updateViewState(showTabBarView: true)
            }
        }
    }
    
    // MARK: - Logs
    enum Event: LoggableEvent {
        case signInWithApple, signInWithEmail
        case didSignIn(isNewUser: Bool)
        
        static var screenName: String = "WelcomeView"
        
        var eventName: String {
            switch self {
            case .signInWithApple:          return "\(Event.screenName)_SignIn_Apple"
            case .signInWithEmail:          return "\(Event.screenName)_SignIn_Email"
            case .didSignIn:                return "\(Event.screenName)_DidSignIn"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .didSignIn(isNewUser: let isNewUser):
                return ["welcome_is_new_user": isNewUser]
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            default:
                    .analytic
            }
        }
    }
}

#Preview {
    NavigationStack {
        WelcomeView()
            .previewEnvironment()
    }
}
