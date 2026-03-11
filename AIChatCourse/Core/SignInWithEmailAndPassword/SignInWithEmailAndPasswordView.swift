//
//  SignInWithEmailAndPasswordView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 08.01.2026.
//

import SwiftUI

struct SignInWithEmailAndPasswordView: View {
    private enum Field {
        case email
        case password
    }
    
    @State var viewModel: SignInWithEmailAndPasswordViewModel
    @Environment(DependencyContainer.self) private var container
    @Environment(\.dismiss) private var dismiss

    var onDidSignIn: (_ isNewUser: Bool) -> Void
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    loginForm
                }
                
                ctaButtons
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Image(systemName: "xmark")
                        .foregroundStyle(.accent)
                        .anyButton {
                            dismiss()
                        }
                }
            }
            .screenAppearAnalytics(name: "SignInWithEmailAndPasswordView")
        }
    }
    
    private var loginForm: some View {
        VStack(alignment: .leading, spacing: 40) {
            Text("Welcome back! Glad to see you, Again!")
                .foregroundStyle(.black)
                .font(.title)
                .padding(.top, 40)
            
            VStack(spacing: 28) {
                FloatingTextField(
                    text: $viewModel.email,
                    placeholder: "Email",
                    leftIcon: "person.fill",
                    rightIcon: nil
                )
                
                FloatingTextField(secureText: $viewModel.password)
            }
        }
        .padding(.horizontal)
    }
    
    private var ctaButtons: some View {
        VStack(spacing: 10) {
            Text("Login")
                .callToActionButton()
                .anyButton {
                    viewModel.onLoginPressed { isNewUser in
                        onDidSignIn(isNewUser)
                        dismiss()
                    }
                }
    
            HStack(spacing: 4) {
                Text("Don't have an account?")
                    .foregroundStyle(.secondary)
                    .font(.callout)
                
                NavigationLink {
                    SignUpWithEmailAndPasswordView(viewModel: .init(interactor: CoreInteractor(container: container)))
                } label: {
                    Text("Register Now")
                        .foregroundStyle(.accent)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
}

#Preview {
    SignInWithEmailAndPasswordView(
        viewModel: SignInWithEmailAndPasswordViewModel(
            interactor: CoreInteractor(
                container: DevPreview.shared.container
            )
        )
    ) { isNewUser in
        print("\(isNewUser)")
    }
    .previewEnvironment()
}
