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
    @Environment(LogManager.self) private var logManager
    @Environment(PurchaseManager.self) private var purchaseManager
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
                onSignInPressed()
            }
            
            Spacer()
        }
        .padding(16)
        .padding(.top, 40)
        .screenAppearAnalytics(name: "CreateAccountWithAppleView")
    }
    
    private func onSignInPressed() {
        logManager.trackEvent(event: Event.appleAuthStart)
        Task {
            do {
                let result = try await authManager.signInWithApple()
                logManager.trackEvent(event: Event.appleAuthSuccess(user: result.user, isNewUser: result.isNewUser))
                
                try await userManager.logIn(auth: result.user, isNewUser: result.isNewUser)
                try await purchaseManager.logIn(userId: result.user.uid, attributes: .init(email: result.user.email))
                logManager.trackEvent(event: Event.appleAuthLoginSucess(user: result.user, isNewUser: result.isNewUser))
                
                dismiss()
                onDidSignIn?(result.isNewUser)
            } catch {
                logManager.trackEvent(event: Event.appleAuthFail(error: error))
            }
        }
    }
    
    enum Event: LoggableEvent {
        case appleAuthStart
        case appleAuthSuccess(user: UserAuthInfo, isNewUser: Bool)
        case appleAuthLoginSucess(user: UserAuthInfo, isNewUser: Bool)
        case appleAuthFail(error: Error)
        
        static var screenName: String = "CreateAccountWithAppleView"
        
        var eventName: String {
            switch self {
            case .appleAuthStart:           return "\(Event.screenName)_AppleAuth_Start"
            case .appleAuthSuccess:         return "\(Event.screenName)_AppleAuth_Success"
            case .appleAuthLoginSucess:     return "\(Event.screenName)_AppleAuth_LoginSuccess"
            case .appleAuthFail:            return "\(Event.screenName)_AppleAuth_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .appleAuthFail(error: let error):
                return error.eventParameters
            case .appleAuthSuccess(user: let user, isNewUser: let isNewUser), .appleAuthLoginSucess(user: let user, isNewUser: let isNewUser):
                var dict = user.eventParameters
                dict["uauth_is_new_user"] = isNewUser
                return dict
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .appleAuthFail:
                    .severe
            default:
                    .analytic
            }
        }
    }
}

#Preview {
    CreateAccountWithAppleView { newUser in
        print("newUser:\(newUser)")
    }
    .previewEnvironment()
}
