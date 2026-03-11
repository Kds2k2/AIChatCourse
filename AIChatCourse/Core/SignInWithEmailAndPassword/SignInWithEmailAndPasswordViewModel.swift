//
//  SignInWithEmailAndPasswordViewModel.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 10.03.2026.
//

import SwiftUI

@MainActor
protocol SignInWithEmailAndPasswordInteractor {
    func trackEvent(event: LoggableEvent)
    func signInWithEmailAndPassword(email: String,password: String) async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws
}

extension CoreInteractor: SignInWithEmailAndPasswordInteractor { }

@Observable
@MainActor
class SignInWithEmailAndPasswordViewModel {
    let interactor: SignInWithEmailAndPasswordInteractor
    
    var email: String = "test@gmail.com"
    var password: String = "Password12345!"
    
    init(interactor: SignInWithEmailAndPasswordInteractor) {
        self.interactor = interactor
    }
    
    func onLoginPressed(onDidSignInSuccessfully: @escaping (_ isNewUser: Bool) -> Void) {
        interactor.trackEvent(event: Event.loginStart)
        Task {
            do {
                let result = try await interactor.signInWithEmailAndPassword(email: email, password: password)
                interactor.trackEvent(event: Event.loginAuthSuccess(user: result.user, isNewUser: result.isNewUser))
                
                try await interactor.logIn(auth: result.user, isNewUser: result.isNewUser)
                interactor.trackEvent(event: Event.loginUserSuccess(user: result.user, isNewUser: result.isNewUser))
                
                onDidSignInSuccessfully(result.isNewUser)
            } catch {
                interactor.trackEvent(event: Event.loginFail(error: error))
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
