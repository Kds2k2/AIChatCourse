//
//  AppViewModel.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 12.03.2026.
//

import SwiftUI

@MainActor
protocol AppInteractor {
    var auth: UserAuthInfo? { get }
    
    func trackEvent(event: LoggableEvent)
    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws
    func singInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool)
}

extension CoreInteractor: AppInteractor { }

@Observable
@MainActor
class AppViewModel {
    let interactor: AppInteractor
    
    init(interactor: AppInteractor) {
        self.interactor = interactor
    }
    
    // MARK: - Loading
    func checkUserStatus() async {
        if let user = interactor.auth {
            interactor.trackEvent(event: Event.existingAuthStart)
            
            do {
                try await interactor.logIn(auth: user, isNewUser: false)
            } catch {
                interactor.trackEvent(event: Event.existingAuthFail(error: error))
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        } else {
            interactor.trackEvent(event: Event.anonAuthStart)
            do {
                let result = try await interactor.singInAnonymously()
                interactor.trackEvent(event: Event.anonAuthSuccess)
                try await interactor.logIn(auth: result.user, isNewUser: result.isNewUser)
            } catch {
                interactor.trackEvent(event: Event.anonAuthFail(error: error))
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        }
    }
    
    func showATTPromptIfNeeded() async {
        #if !DEBUG
        let status = await AppTrackingTransparencyHelper.requestTrackingAuthorization()
        logManager.trackEvent(event: Event.attStatus(dict: status.eventParameters))
        #endif
    }
    
    // MARK: - Logs
    enum Event: LoggableEvent {
        case existingAuthStart, existingAuthFail(error: Error)
        case anonAuthStart, anonAuthSuccess, anonAuthFail(error: Error)
        case attStatus(dict: [String: Any])
        
        var eventName: String {
            switch self {
            case .existingAuthStart: "AppView_ExistingAuth_Start"
            case .existingAuthFail: "AppView_ExistingAuth_Fail"
            case .anonAuthStart: "AppView_AnonAuth_Start"
            case .anonAuthSuccess: "AppView_AnonAuth_Success"
            case .anonAuthFail: "AppView_AnonAuth_Fail"
            case .attStatus: "AppView_ATTStatus"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .existingAuthFail(error: let error), .anonAuthFail(error: let error):
                return error.eventParameters
            case .attStatus(dict: let dict):
                return dict
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .existingAuthFail, .anonAuthFail:
                .severe
            default:
                .analytic
            }
        }
    }
}
