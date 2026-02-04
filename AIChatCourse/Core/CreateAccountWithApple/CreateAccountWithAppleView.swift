//
//  CreateAccountView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 04.01.2026.
//
import SwiftUI
import FirebaseAuth
import SignInAppleAsync
import AuthenticationServices
import CryptoKit

struct CreateAccountWithAppleView: View {
    @Environment(AppState.self) private var root
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(\.dismiss) private var dismiss
    
    var onDidSignIn: ((_ isNewUser: Bool) -> Void)?
    
    var title: String = "Create Account?"
    var subtitle: String = "Don't lose your data! Connect to an SSO provider to save your account."
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                Text(subtitle)
                    .font(.body)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            SignInWithAppleButtonView(
                type: .signIn,
                style: .black,
                cornerRadius: 10
            )
            .frame(height: 55)
            .anyButton(.press) {
                onSignInPressed()
            }
            
            Spacer()
        }
        .padding(16)
        .padding(.top, 40)
    }
    
    private func onSignInPressed() {
        Task {
            do {
                let result = try await authManager.signInWithApple()
                print("Apple, sign in success")
                try await userManager.logIn(auth: result.user, isNewUser: result.isNewUser)
                print("Apple, log in success")
                
                dismiss()
                onDidSignIn?(result.isNewUser)
            } catch {
                print("onLoginPressed: \(error)")
            }
        }
    }
}

#Preview {
    CreateAccountWithAppleView { newUser in
        print("newUser:\(newUser)")
    }
}
