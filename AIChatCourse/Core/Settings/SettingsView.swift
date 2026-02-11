//
//  SettingsView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 31.12.2025.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(ChatManager.self) private var chatManager
    @Environment(AppState.self) private var appState
    @Environment(LogManager.self) private var logManager

    @State private var isPremium: Bool = false
    var premiumTitle: String {
        return isPremium ? "PREMIUM" : "FREE"
    }
    
    @State private var isAnonymousUser: Bool = true
    @State private var showCreateAccountMenu: AnyAppAlert?
    @State private var showAppleProvider: Bool = false
    @State private var showEmailProvider: Bool = false
    
    @State private var showAlert: AnyAppAlert?
    @State private var showRatingsModal: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                accountSection
                purchaseSection
                applicationSection
            }
            .environment(\.defaultMinListRowHeight, 0)
            .navigationTitle("Settings")
            .screenAppearAnalytics(name: "SettignsScreen")
            .showCustomAlert(type: .confirmationDialog, alert: $showCreateAccountMenu)
            .sheet(isPresented: $showAppleProvider, onDismiss: {
                setAnonymousAccountStatus()
            }, content: {
                CreateAccountWithAppleView()
                    .presentationDetents([.medium])
            })
            .sheet(isPresented: $showEmailProvider, onDismiss: {
                setAnonymousAccountStatus()
            }, content: {
                SignUpWithEmailAndPasswordView()
            })
            .onAppear {
                setAnonymousAccountStatus()
            }
            .showCustomAlert(alert: $showAlert)
            .showModal($showRatingsModal) {
                ratingsModal
            }
        }
    }
    
    // MARK: - Views
    private var accountSection: some View {
        Section {
            if isAnonymousUser {
                Text("Save & back-up account")
                    .rowFormatting()
                    .anyButton(.highlight) {
                        onCreateAccountPressed()
                    }
                    .removeListRowFormatting()
            } else {
                Text("Sign out")
                    .rowFormatting()
                    .anyButton(.highlight) {
                        onSignOutPressed()
                    }
                    .removeListRowFormatting()
            }
            
            Text("Delete account")
                .foregroundStyle(.red)
                .rowFormatting()
                .anyButton(.highlight) {
                    onDeleteAccountPressed()
                }
                .removeListRowFormatting()
        } header: {
            Text("Account")
        }
    }
    
    private var purchaseSection: some View {
        Section {
            HStack {
                Text("Account status: " + premiumTitle)
                Spacer(minLength: 0)
                if isPremium {
                    Text("MANAGE")
                        .badgeButton()
                }
            }
            .rowFormatting()
            .anyButton(.highlight) {
                // action
            }
            .disabled(!isPremium)
            .removeListRowFormatting()
        } header: {
            Text("Purchases")
        }
    }
    
    private var applicationSection: some View {
        Section {
            Text("Rate us on the App Store!")
                .foregroundStyle(.blue)
                .rowFormatting()
                .anyButton(.highlight) {
                    onRatingButtonPressed()
                }
                .removeListRowFormatting()
            
            HStack {
                Text("Version")
                Spacer(minLength: 0)
                Text(AppInfo.appVersion ?? "")
                    .foregroundStyle(.secondary)
            }
            .rowFormatting()
            .removeListRowFormatting()
            
            HStack {
                Text("Build Number")
                Spacer(minLength: 0)
                Text(AppInfo.buildNumber ?? "")
                    .foregroundStyle(.secondary)
            }
            .rowFormatting()
            .removeListRowFormatting()
            
            Text("Contact us")
                .foregroundStyle(.blue)
                .rowFormatting()
                .anyButton(.highlight) {
                    onContactUsPressed()
                }
                .removeListRowFormatting()
        } header: {
            Text("Application")
        } footer: {
            Text("Created by Dmitro Kryzhanovsky.")
                .baselineOffset(6)
        }
    }
    
    private var ratingsModal: some View {
        CustomModalView(
            title: "Are you enjoying AIChat?",
            subtitle: "We'd love to hear your feedback!",
            primaryButtonTitle: "Yes",
            primaryButtonAction: {
                onEnjoyingAppPressed()
            },
            secondaryButtonTitle: "No",
            secondaryButtonAction: {
                onEnjoyingAppNoPressed()
            }
        )
    }
    
    // MARK: - Actions
    private func setAnonymousAccountStatus() {
        isAnonymousUser = authManager.auth?.isAnonymous == true
    }
    
    private func onContactUsPressed() {
        logManager.trackEvent(event: Event.contactUsPressed)
        let email = "dimakruzha.dev@gmail.com"
        let emailString = "mailto:\(email)"
        
        guard let url = URL(string: emailString), UIApplication.shared.canOpenURL(url) else { return }
        
        UIApplication.shared.open(url)
    }
    
    private func onRatingButtonPressed() {
        logManager.trackEvent(event: Event.ratingUsPressed)
        showRatingsModal = true
    }
    
    private func onEnjoyingAppPressed() {
        logManager.trackEvent(event: Event.ratingYesPressed)
        showRatingsModal = false
        AppStoreRatingHelper().requestRatingsReview()
    }
    
    private func onEnjoyingAppNoPressed() {
        logManager.trackEvent(event: Event.ratingNoPressed)
        showRatingsModal = false
    }
    
    private func onCreateAccountPressed() {
        showCreateAccountMenu = AnyAppAlert(
            title: "",
            subtitle: "Select provider",
            buttons: {
                AnyView(
                    Group {
                        Button("Apple", role: .destructive) {
                            showAppleProvider = true
                            logManager.trackEvent(event: Event.createAccountWithApple)
                        }
                        Button("Email", role: .destructive) {
                            showEmailProvider = true
                            logManager.trackEvent(event: Event.createAccountWithEmail)
                        }
                    }
                )
            }
        )
    }
    
    private func onSignOutPressed() {
        logManager.trackEvent(event: Event.signOuntStart)
        Task {
            do {
                try authManager.signOut()
                userManager.signOut()
                logManager.trackEvent(event: Event.signOutSuccess)
                
                await dismissScreen()
            } catch {
                showAlert = AnyAppAlert(error: error)
                logManager.trackEvent(event: Event.signOutFail(error: error))
            }
        }
    }
    
    private func onDeleteAccountPressed() {
        logManager.trackEvent(event: Event.deleteAccountButtonPressed)
        showAlert = AnyAppAlert(
            title: "Delete Account?",
            subtitle: "This action is permenet and cannot be undone. Your data will be deleted form out server forever.",
            buttons: {
                AnyView(
                    Button("Delete", role: .destructive, action: {
                        onDeleteAccountConfirmed()
                    })
                )
            }
        )
    }
    
    private func onDeleteAccountConfirmed() {
        logManager.trackEvent(event: Event.deleteAccountStart)
        Task {
            do {
                let uid = try authManager.getAuthId()
                
                async let deleteAuth: () = authManager.deleteAccount()
                async let deleteUser: () = userManager.deleleCurrentUser()
                async let deleteAvatars: () = avatarManager.removeAuthorIdFromAllUserAvatars(userId: uid)
                async let deleteChats: () = chatManager.deleteAllChatsForUser(userId: uid)
                async let deleteAnalytics: () = logManager.deleteUserProfile()
                
                let (_, _, _, _, _) = try await (deleteAuth, deleteUser, deleteAvatars, deleteChats, deleteAnalytics)
                logManager.trackEvent(event: Event.deleteAccountSuccess)
                
                await dismissScreen()
            } catch {
                showAlert = AnyAppAlert(error: error)
                logManager.trackEvent(event: Event.deleteAccountFail(error: error))
            }
        }
    }
    
    private func dismissScreen() async {
        dismiss()
        appState.updateViewState(showTabBarView: false)
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

fileprivate extension View {
    func rowFormatting() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading) // var 1: minHeight: 28
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color(uiColor: .systemBackground))
    }
}

// MARK: - Previews
#Preview("No auth") {
    SettingsView()
        .environment(AuthManager(service: MockAuthService(user: nil)))
        .environment(UserManager(services: MockUserServices(user: nil)))
        .previewEnvironment()
}

#Preview("Anon") {
    SettingsView()
        .environment(AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: true))))
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .previewEnvironment()
}

#Preview("Not anon") {
    SettingsView()
        .environment(AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: false))))
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .previewEnvironment()
}
