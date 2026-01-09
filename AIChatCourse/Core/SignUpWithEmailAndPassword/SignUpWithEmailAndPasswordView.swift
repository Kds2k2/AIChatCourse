//
//  SignUpWithEmailAndPasswordView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 08.01.2026.
//

import SwiftUI

struct SignUpWithEmailAndPasswordView: View {
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
            Text("Register")
                .callToActionButton()
                .anyButton {
                    onRegisterPressed()
                }
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }

    private func onRegisterPressed() {
        Task {
            _ = try? await authService.signUpWithEmailAndPassword(email: email, password: password)
            dismiss()
        }
    }
}

#Preview {
    SignUpWithEmailAndPasswordView()
        .environment(AppState())
}
