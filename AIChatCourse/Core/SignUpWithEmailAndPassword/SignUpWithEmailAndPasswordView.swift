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
    
    @State var viewModel: SignUpWithEmailAndPasswordViewModel
    @Environment(\.dismiss) private var dismiss
    
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
            .screenAppearAnalytics(name: "SignUpWithEmailAndPasswordView")
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
            Text("Register")
                .callToActionButton()
                .anyButton {
                    viewModel.onRegisterPressed {
                        dismiss()
                    }
                }
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
}

#Preview {
    SignUpWithEmailAndPasswordView(viewModel: SignUpWithEmailAndPasswordViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)))
        .previewEnvironment()
}
