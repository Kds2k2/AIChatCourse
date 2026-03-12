//
//  WelcomeViewModel.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 11.03.2026.
//

import SwiftUI

@MainActor
protocol WelcomeInteractor {
    func trackEvent(event: LoggableEvent)
    func updateAppState(showTabBar: Bool)
}

extension CoreInteractor: WelcomeInteractor { }

@Observable
@MainActor
class WelcomeViewModel {
    let interactor: WelcomeInteractor
    
    private(set) var imageName: String = Constants.randomImage
    
    var path: [OnboardingPathOption] = []
    var showCreateAccountMenu: AnyAppAlert?
    var showAppleProvider: Bool = false
    var showEmailProvider: Bool = false
    
    init(interactor: WelcomeInteractor) {
        self.interactor = interactor
    }
    
    func onGetStartedPressed() {
        path.append(.intro)
    }
    
    func onSignInPressed() {
        showCreateAccountMenu = AnyAppAlert(
            title: "",
            subtitle: "Select provider",
            buttons: {
                AnyView(
                    Group {
                        Button("Apple", role: .destructive) {
                            self.showAppleProvider = true
                            self.interactor.trackEvent(event: Event.signInWithApple)
                        }
                        Button("Email", role: .destructive) {
                            self.showEmailProvider = true
                            self.interactor.trackEvent(event: Event.signInWithEmail)
                        }
                    }
                )
            }
        )
    }
    
    func handleDidSignIn(isNewUser: Bool) {
        interactor.trackEvent(event: Event.didSignIn(isNewUser: isNewUser))
        if isNewUser {
            // Do nothing
        } else {
            Task {
                try? await Task.sleep(for: .seconds(0.5))
                interactor.updateAppState(showTabBar: true)
            }
        }
    }
    
    // MARK: - Logs
    enum Event: LoggableEvent {
        case signInWithApple, signInWithEmail
        case didSignIn(isNewUser: Bool)
        
        static var screenName: String = "WelcomeView"
        
        var eventName: String {
            switch self {
            case .signInWithApple:          return "\(Event.screenName)_SignIn_Apple"
            case .signInWithEmail:          return "\(Event.screenName)_SignIn_Email"
            case .didSignIn:                return "\(Event.screenName)_DidSignIn"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .didSignIn(isNewUser: let isNewUser):
                return ["welcome_is_new_user": isNewUser]
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            default:
                    .analytic
            }
        }
    }
}
