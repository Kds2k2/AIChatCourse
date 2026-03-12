//
//  OnboardingCompletedViewModel.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 12.03.2026.
//

import SwiftUI

@MainActor
protocol OnboardingCompletedInteractor {
    func trackEvent(event: LoggableEvent)
    func markOnboardingCompletedForCurrentUser(profileColorHex: String) async throws
}

extension CoreInteractor: OnboardingCompletedInteractor { }

@Observable
@MainActor
class OnboardingCompletedViewModel {
    let interactor: OnboardingCompletedInteractor
    
    private(set) var isCompletingProfileSetup: Bool = false
    
    var showAlert: AnyAppAlert?
    
    init(interactor: OnboardingCompletedInteractor) {
        self.interactor = interactor
    }
    
    func onFinishButtonPressed(selectedColor: Color, onCompletion: @escaping () -> Void) {
        isCompletingProfileSetup = true
        interactor.trackEvent(event: Event.finishStart)
        
        Task {
            do {
                let hex = selectedColor.toHex()
                try await interactor.markOnboardingCompletedForCurrentUser(profileColorHex: hex)
                interactor.trackEvent(event: Event.finishSuccess(hex: hex))
                
                // dismiss screen
                isCompletingProfileSetup = false
                onCompletion()
            } catch {
                showAlert = AnyAppAlert(error: error)
                interactor.trackEvent(event: Event.finishFail(error: error))
            }
        }
    }
    
    enum Event: LoggableEvent {
        case finishStart, finishSuccess(hex: String), finishFail(error: Error)
        
        static var screenName: String = "OnboardingCompletedView"
        
        var eventName: String {
            switch self {
            case .finishStart:      return "\(Event.screenName)_Finish_Start"
            case .finishSuccess:    return "\(Event.screenName)_Finish_Success"
            case .finishFail:       return "\(Event.screenName)_Finish_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .finishFail(error: let error):
                return error.eventParameters
            case .finishSuccess(hex: let hex):
                return ["hex_color": hex]
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .finishFail:
                    .severe
            default:
                    .analytic
            }
        }
    }
}
