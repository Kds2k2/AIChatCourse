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
    
    @Environment(AppState.self) private var root
    @Environment(\.authService) private var authService
    @Environment(\.dismiss) private var dismiss
    
    @State var email: String = "test@gmail.com"
    @State var password: String = "Password12345!"

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
                    text: $email,
                    placeholder: "Email",
                    leftIcon: "person.fill",
                    rightIcon: nil
                )
                
                FloatingTextField(secureText: $password)
            }
        }
        .padding(.horizontal)
    }
    
    private var ctaButtons: some View {
        VStack(spacing: 10) {
            Text("Login")
                .callToActionButton()
                .anyButton {
                    onLoginPressed()
                }
    
            HStack(spacing: 4) {
                Text("Don't have an account?")
                    .foregroundStyle(.secondary)
                    .font(.callout)
                
                NavigationLink {
                    SignUpWithEmailAndPasswordView()
                } label: {
                    Text("Register Now")
                        .foregroundStyle(.accent)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }

    private func onLoginPressed() {
        Task {
            _ = try? await authService.signInWithEmailAndPassword(email: email, password: password)
            dismiss()
            try? await Task.sleep(for: .seconds(1))
            root.updateViewState(showTabBarView: true)
        }
    }
}

#Preview {
    SignInWithEmailAndPasswordView()
        .environment(AppState())
}
