//
//  CreateAccountView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 04.01.2026.
//
import SwiftUI
import AuthenticationServices

struct CreateAccountView: View {
    @State private var authorizationResult: ASAuthorization?
    @State private var error: Error?
    
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

            SignInWithAppleButton(.signIn, onRequest: { request in
                request.requestedScopes = [.fullName, .email]
            }, onCompletion: { result in
                switch result {
                case .success(let authResult):
                    self.error = nil
                    self.authorizationResult = authResult
                    print("+")
                case .failure(let error):
                    self.error = error
                    self.authorizationResult = nil
                    print("-")
                }
            })
            .signInWithAppleButtonStyle(.black)
            .frame(height: 55)
            
            Spacer()
        }
        .padding(16)
        .padding(.top, 40)
    }
}

#Preview {
    CreateAccountView()
}
