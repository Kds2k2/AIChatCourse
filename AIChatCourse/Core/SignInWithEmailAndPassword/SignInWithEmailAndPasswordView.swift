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
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    @Environment(PurchaseManager.self) private var purchaseManager
    @Environment(\.dismiss) private var dismiss
    
    @State var email: String = "test@gmail.com"
    @State var password: String = "Password12345!"

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
        logManager.trackEvent(event: Event.loginStart)
        Task {
            do {
                let result = try await authManager.signInWithEmailAndPassword(email: email, password: password)
                logManager.trackEvent(event: Event.loginAuthSuccess(user: result.user, isNewUser: result.isNewUser))
                
                try await userManager.logIn(auth: result.user, isNewUser: result.isNewUser)
                try await purchaseManager.logIn(userId: result.user.uid, attributes: .init(email: result.user.email))
                logManager.trackEvent(event: Event.loginUserSuccess(user: result.user, isNewUser: result.isNewUser))
                
                dismiss()
                onDidSignIn(result.isNewUser)
            } catch {
                logManager.trackEvent(event: Event.loginFail(error: error))
            }
        }
    }
    
    enum Event: LoggableEvent {
        case loginStart
        case loginAuthSuccess(user: UserAuthInfo, isNewUser: Bool)
        case loginUserSuccess(user: UserAuthInfo, isNewUser: Bool)
        case loginFail(error: Error)
        
        static var screenName: String = "SignInWithEmailAndPasswordView"
        
        var eventName: String {
            switch self {
            case .loginStart:               return "\(Event.screenName)_Login_Start"
            case .loginAuthSuccess:         return "\(Event.screenName)_LoginAuth_Success"
            case .loginUserSuccess:         return "\(Event.screenName)_LoginUser_Success"
            case .loginFail:                return "\(Event.screenName)_Login_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loginFail(error: let error):
                return error.eventParameters
            case .loginAuthSuccess(user: let user, isNewUser: let isNewUser), .loginUserSuccess(user: let user, isNewUser: let isNewUser):
                var dict = user.eventParameters
                dict["login_is_new_user"] = isNewUser
                return dict
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loginFail:
                    .severe
            default:
                    .analytic
            }
        }
    }
}

#Preview {
    SignInWithEmailAndPasswordView { isNewUser in
        print("\(isNewUser)")
    }
    .previewEnvironment()
}
