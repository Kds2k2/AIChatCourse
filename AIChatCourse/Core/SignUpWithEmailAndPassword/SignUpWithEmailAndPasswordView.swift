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
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
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
        logManager.trackEvent(event: Event.registerStart)
        Task {
            do {
                let result = try await authManager.signUpWithEmailAndPassword(email: email, password: password)
                logManager.trackEvent(event: Event.registerSuccess(user: result.user, isNewUser: result.isNewUser))
                
                try await userManager.logIn(auth: result.user, isNewUser: result.isNewUser)
                logManager.trackEvent(event: Event.loginUserSuccess(user: result.user, isNewUser: result.isNewUser))
            } catch {
                logManager.trackEvent(event: Event.registerFail(error: error))
            }
            
            dismiss()
        }
    }
    
    enum Event: LoggableEvent {
        case registerStart
        case registerSuccess(user: UserAuthInfo, isNewUser: Bool)
        case loginUserSuccess(user: UserAuthInfo, isNewUser: Bool)
        case registerFail(error: Error)
        
        static var screenName: String = "SignUpWithEmailAndPasswordView"
        
        var eventName: String {
            switch self {
            case .registerStart:               return "\(Event.screenName)_Register_Start"
            case .registerSuccess:             return "\(Event.screenName)_Register_Success"
            case .loginUserSuccess:            return "\(Event.screenName)_LoginUser_Success"
            case .registerFail:                return "\(Event.screenName)_Register_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .registerFail(error: let error):
                return error.eventParameters
            case .registerSuccess(user: let user, isNewUser: let isNewUser), .loginUserSuccess(user: let user, isNewUser: let isNewUser):
                var dict = user.eventParameters
                dict["register_is_new_user"] = isNewUser
                return dict
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .registerFail:
                    .severe
            default:
                    .analytic
            }
        }
    }
}

#Preview {
    SignUpWithEmailAndPasswordView()
        .environment(AppState())
}
