//
//  SettingsViewModel.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 11.03.2026.
//

import SwiftUI

@MainActor
protocol SettingsInteractor {
    var auth: UserAuthInfo? { get }
    
    func trackEvent(event: LoggableEvent)
    func updateAppState(showTabBar: Bool)
    func getAuthId() throws -> String
    func signOut() async throws
    func deleteAccount(userId: String) async throws
}

extension CoreInteractor: SettingsInteractor { }

@Observable
@MainActor
class SettingsViewModel {
    let interactor: SettingsInteractor
    
    private(set) var isAnonymousUser: Bool = true
    private(set) var isPremium: Bool = false
    
    var showCreateAccountMenu: AnyAppAlert?
    var showAppleProvider: Bool = false
    var showEmailProvider: Bool = false
    var showAlert: AnyAppAlert?
    var showRatingsModal: Bool = false
    
    var premiumTitle: String {
        return isPremium ? "PREMIUM" : "FREE"
    }
    
    init(interactor: SettingsInteractor) {
        self.interactor = interactor
    }
    
    // MARK: - Actions
    func setAnonymousAccountStatus() {
        isAnonymousUser = interactor.auth?.isAnonymous == true
    }
    
    func onContactUsPressed() {
        interactor.trackEvent(event: Event.contactUsPressed)
        let email = "dimakruzha.dev@gmail.com"
        let emailString = "mailto:\(email)"
        
        guard let url = URL(string: emailString), UIApplication.shared.canOpenURL(url) else { return }
        
        UIApplication.shared.open(url)
    }
    
    func onRatingButtonPressed() {
        interactor.trackEvent(event: Event.ratingUsPressed)
        showRatingsModal = true
    }
    
    func onEnjoyingAppPressed() {
        interactor.trackEvent(event: Event.ratingYesPressed)
        showRatingsModal = false
        AppStoreRatingHelper().requestRatingsReview()
    }
    
    func onEnjoyingAppNoPressed() {
        interactor.trackEvent(event: Event.ratingNoPressed)
        showRatingsModal = false
    }
    
    func onCreateAccountPressed() {
        showCreateAccountMenu = AnyAppAlert(
            title: "",
            subtitle: "Select provider",
            buttons: {
                AnyView(
                    Group {
                        Button("Apple", role: .destructive) {
                            self.showAppleProvider = true
                            self.interactor.trackEvent(event: Event.createAccountWithApple)
                        }
                        Button("Email", role: .destructive) {
                            self.showEmailProvider = true
                            self.interactor.trackEvent(event: Event.createAccountWithEmail)
                        }
                    }
                )
            }
        )
    }
    
    func onSignOutPressed(onDismiss: @escaping () async -> Void) {
        interactor.trackEvent(event: Event.signOuntStart)
        Task {
            do {
                try await interactor.signOut()
                interactor.trackEvent(event: Event.signOutSuccess)
                
                await onDismiss()
                interactor.updateAppState(showTabBar: false)
            } catch {
                showAlert = AnyAppAlert(error: error)
                interactor.trackEvent(event: Event.signOutFail(error: error))
            }
        }
    }
    
    func onDeleteAccountPressed(onDismiss: @escaping () async -> Void) {
        interactor.trackEvent(event: Event.deleteAccountButtonPressed)
        showAlert = AnyAppAlert(
            title: "Delete Account?",
            subtitle: "This action is permenet and cannot be undone. Your data will be deleted form out server forever.",
            buttons: {
                AnyView(
                    Button("Delete", role: .destructive, action: {
                        self.onDeleteAccountConfirmed(onDismiss: onDismiss)
                    })
                )
            }
        )
    }
    
    func onDeleteAccountConfirmed(onDismiss: @escaping () async -> Void) {
        interactor.trackEvent(event: Event.deleteAccountStart)
        Task {
            do {
                let uid = try interactor.getAuthId()
                try await interactor.deleteAccount(userId: uid)
                interactor.trackEvent(event: Event.deleteAccountSuccess)
                
                await onDismiss()
                interactor.updateAppState(showTabBar: false)
            } catch {
                showAlert = AnyAppAlert(error: error)
                interactor.trackEvent(event: Event.deleteAccountFail(error: error))
            }
        }
    }
    
    // MARK: - Logs
    enum Event: LoggableEvent {
        case createAccountWithApple, createAccountWithEmail
        case signOuntStart, signOutSuccess, signOutFail(error: Error)
        case deleteAccountButtonPressed
        case deleteAccountStart, deleteAccountSuccess, deleteAccountFail(error: Error)
        case contactUsPressed
        case ratingUsPressed, ratingYesPressed, ratingNoPressed
        
        static var screenName: String = "SettingsView"
        
        var eventName: String {
            switch self {
            case .createAccountWithApple:               return "\(Event.screenName)_CreateAccount_Apple"
            case .createAccountWithEmail:               return "\(Event.screenName)_CreateAccount_Email"
            case .signOuntStart:                        return "\(Event.screenName)_SignOut_Start"
            case .signOutSuccess:                       return "\(Event.screenName)_SignOut_Success"
            case .signOutFail:                          return "\(Event.screenName)_SignOut_Fail"
            case .deleteAccountButtonPressed:           return "\(Event.screenName)_DeleteAccountButton_Pressed"
            case .deleteAccountStart:                   return "\(Event.screenName)_DeleteAccount_Start"
            case .deleteAccountSuccess:                 return "\(Event.screenName)_DeleteAccount_Success"
            case .deleteAccountFail:                    return "\(Event.screenName)_DeleteAccount_Fail"
            case .contactUsPressed:                     return "\(Event.screenName)_ContactUs_Pressed"
            case .ratingUsPressed:                      return "\(Event.screenName)_RatingUs_Pressed"
            case .ratingYesPressed:                     return "\(Event.screenName)_RatingYes_Pressed"
            case .ratingNoPressed:                      return "\(Event.screenName)_RatingNo_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .signOutFail(error: let error), .deleteAccountFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .signOutFail, .deleteAccountFail:
                    .severe
            default:
                    .analytic
            }
        }
    }
}
