//
//  SignUpWithEmailAndPasswordViewModel.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 10.03.2026.
//

import SwiftUI

@MainActor
protocol SignUpWithEmailAndPasswordInteractor {
    func trackEvent(event: LoggableEvent)
    func signUpWithEmailAndPassword(email: String, password: String) async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws
}

extension CoreInteractor: SignUpWithEmailAndPasswordInteractor { }

@Observable
@MainActor
class SignUpWithEmailAndPasswordViewModel {
    let interactor: SignUpWithEmailAndPasswordInteractor
    
    var email: String = "test@gmail.com"
    var password: String = "Password12345!"
    
    init(interactor: SignUpWithEmailAndPasswordInteractor) {
        self.interactor = interactor
    }
    
    func onRegisterPressed(onDismiss: @escaping () -> Void) {
        interactor.trackEvent(event: Event.registerStart)
        Task {
            do {
                let result = try await interactor.signUpWithEmailAndPassword(email: email, password: password)
                interactor.trackEvent(event: Event.registerSuccess(user: result.user, isNewUser: result.isNewUser))
                
                try await interactor.logIn(auth: result.user, isNewUser: result.isNewUser)
                interactor.trackEvent(event: Event.loginUserSuccess(user: result.user, isNewUser: result.isNewUser))
            } catch {
                interactor.trackEvent(event: Event.registerFail(error: error))
            }
            
            onDismiss()
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
