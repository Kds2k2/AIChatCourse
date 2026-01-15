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
    @Environment(AppState.self) private var appState

    @State private var isPremium: Bool = true
    var premiumTitle: String {
        return isPremium ? "PREMIUM" : "FREE"
    }
    
    @State private var isAnonymousUser: Bool = true
    @State private var showCreateAccountView: Bool = false
    
    @State private var showAlert: AnyAppAlert?
    
    var body: some View {
        NavigationStack {
            List {
                accountSection
                purchaseSection
                applicationSection
            }
            .environment(\.defaultMinListRowHeight, 0)
            .navigationTitle("Settings")
            .sheet(isPresented: $showCreateAccountView, onDismiss: {
                setAnonymousAccountStatus()
            }, content: {
                SignUpWithEmailAndPasswordView()
            })
            .onAppear {
                setAnonymousAccountStatus()
            }
            .showCustomAlert(alert: $showAlert)
        }
    }
    
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
                    // action
                }
                .removeListRowFormatting()
        } header: {
            Text("Application")
        } footer: {
            Text("Created by Dmitro Kryzhanovsky.\nLearn more at www.swiftful-thinking.com.")
                .baselineOffset(6)
        }
    }
    
    private func setAnonymousAccountStatus() {
        isAnonymousUser = authManager.auth?.isAnonymous == true
    }
    
    private func onCreateAccountPressed() {
        showCreateAccountView = true
    }
    
    private func onSignOutPressed() {
        Task {
            do {
                try authManager.signOut()
                userManager.signOut()
                
                await dismissScreen()
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    private func onDeleteAccountPressed() {
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
        Task {
            do {
                let uid = try authManager.getAuthId()
                
                async let deleteAuth: () = authManager.deleteAccount()
                async let deleteUser: () = userManager.deleleCurrentUser()
                async let deleteAvatars: () = avatarManager.removeAuthorIdFromAllUserAvatars(userId: uid)
                
                let (_, _, _) = await (try deleteAuth, try deleteUser, try deleteAvatars)
                
                await dismissScreen()
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    private func dismissScreen() async {
        dismiss()
        appState.updateViewState(showTabBarView: false)
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

#Preview("No auth") {
    SettingsView()
        .environment(AuthManager(service: MockAuthService(user: nil)))
        .environment(UserManager(services: MockUserServices(user: nil)))
        .environment(AppState())
}

#Preview("Anon") {
    SettingsView()
        .environment(AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: true))))
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .environment(AppState())
}

#Preview("Not anon") {
    SettingsView()
        .environment(AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: false))))
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .environment(AppState())
}
