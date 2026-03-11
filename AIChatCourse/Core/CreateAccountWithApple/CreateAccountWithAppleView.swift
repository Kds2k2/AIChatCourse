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
    @State var viewModel: CreateAccountWithAppleViewModel
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
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
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
                viewModel.onSignInPressed { isNewUser in
                    onDidSignIn?(isNewUser)
                    dismiss()
                }
            }
            
            Spacer()
        }
        .padding(16)
        .padding(.top, 40)
        .screenAppearAnalytics(name: "CreateAccountWithAppleView")
    }
}

#Preview {
    CreateAccountWithAppleView(
        viewModel: CreateAccountWithAppleViewModel(
            interactor: CoreInteractor(
                container: DevPreview.shared.container
            )
        ),
        onDidSignIn: { isNewUser in
            print(
                "newUser: \(isNewUser)"
            )
    })
    .previewEnvironment()
}
