//
//  CreateAccountWithAppleViewModel.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 10.03.2026.
//

import SwiftUI

@MainActor
protocol CreateAccountWithAppleInteractor {
    func trackEvent(event: LoggableEvent)
    func signInWithApple() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws
}

extension CoreInteractor: CreateAccountWithAppleInteractor { }

@Observable
@MainActor
class CreateAccountWithAppleViewModel {
    let interactor: CreateAccountWithAppleInteractor
    
    init(interactor: CreateAccountWithAppleInteractor) {
        self.interactor = interactor
    }
    
    func onSignInPressed(onDidSignInSuccessfully: @escaping (_ isNewUser: Bool) -> Void) {
        interactor.trackEvent(event: Event.appleAuthStart)
        Task {
            do {
                let result = try await interactor.signInWithApple()
                interactor.trackEvent(event: Event.appleAuthSuccess(user: result.user, isNewUser: result.isNewUser))
                
                try await interactor.logIn(auth: result.user, isNewUser: result.isNewUser)
                interactor.trackEvent(event: Event.appleAuthLoginSucess(user: result.user, isNewUser: result.isNewUser))
                
                onDidSignInSuccessfully(result.isNewUser)
            } catch {
                interactor.trackEvent(event: Event.appleAuthFail(error: error))
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
