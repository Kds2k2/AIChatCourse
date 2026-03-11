//
//  SettingsView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 31.12.2025.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(DependencyContainer.self) private var container
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    
    @State var viewModel: SettingsViewModel

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
            .showCustomAlert(type: .confirmationDialog, alert: $viewModel.showCreateAccountMenu)
            .sheet(isPresented: $viewModel.showAppleProvider, onDismiss: {
                viewModel.setAnonymousAccountStatus()
            }, content: {
                CreateAccountWithAppleView(viewModel: .init(interactor: CoreInteractor(container: container)))
                    .presentationDetents([.medium])
            })
            .sheet(isPresented: $viewModel.showEmailProvider, onDismiss: {
                viewModel.setAnonymousAccountStatus()
            }, content: {
                SignUpWithEmailAndPasswordView(viewModel: .init(interactor: CoreInteractor(container: container)))
            })
            .onAppear {
                viewModel.setAnonymousAccountStatus()
            }
            .showCustomAlert(alert: $viewModel.showAlert)
            .showModal($viewModel.showRatingsModal) {
                ratingsModal
            }
        }
    }
    
    // MARK: - Views
    private var accountSection: some View {
        Section {
            if viewModel.isAnonymousUser {
                Text("Save & back-up account")
                    .rowFormatting()
                    .anyButton(.highlight) {
                        viewModel.onCreateAccountPressed()
                    }
                    .removeListRowFormatting()
            } else {
                Text("Sign out")
                    .rowFormatting()
                    .anyButton(.highlight) {
                        viewModel.onSignOutPressed {
                            await dismissScreen()
                        }
                    }
                    .removeListRowFormatting()
            }
            
            Text("Delete account")
                .foregroundStyle(.red)
                .rowFormatting()
                .anyButton(.highlight) {
                    viewModel.onDeleteAccountPressed {
                        await dismissScreen()
                    }
                }
                .removeListRowFormatting()
        } header: {
            Text("Account")
        }
    }
    
    private var purchaseSection: some View {
        Section {
            HStack {
                Text("Account status: " + viewModel.premiumTitle)
                Spacer(minLength: 0)
                if viewModel.isPremium {
                    Text("MANAGE")
                        .badgeButton()
                }
            }
            .rowFormatting()
            .anyButton(.highlight) {
                // action
            }
            .disabled(!viewModel.isPremium)
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
                    viewModel.onRatingButtonPressed()
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
                    viewModel.onContactUsPressed()
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
                viewModel.onEnjoyingAppPressed()
            },
            secondaryButtonTitle: "No",
            secondaryButtonAction: {
                viewModel.onEnjoyingAppNoPressed()
            }
        )
    }
    
    func dismissScreen() async {
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

// MARK: - Previews
#Preview("No auth") {
    let container = DevPreview.shared.container
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: nil)))
    container.register(UserManager.self, service: UserManager(services: MockUserServices(user: nil)))

    return SettingsView(viewModel: SettingsViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
}

#Preview("Anon") {
    let container = DevPreview.shared.container
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: true))))
    container.register(UserManager.self, service: UserManager(services: MockUserServices(user: .mock)))

    return SettingsView(viewModel: SettingsViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
}

#Preview("Not anon") {
    let container = DevPreview.shared.container
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: false))))
    container.register(UserManager.self, service: UserManager(services: MockUserServices(user: .mock)))

    return SettingsView(viewModel: SettingsViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
}
