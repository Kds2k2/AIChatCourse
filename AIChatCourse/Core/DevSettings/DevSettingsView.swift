//
//  DevSettingsView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 22.01.2026.
//

import SwiftUI

struct DevSettingsView: View {

    @State var viewModel: DevSettingsViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                abTestSection
                authSection
                userSection
                deviceSection
            }
            .navigationTitle("Dev Settings")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    backButtonView
                }
            }
            .screenAppearAnalytics(name: "DevSettings")
            .onFirstAppear {
                viewModel.loadABTests()
            }
        }
    }
    
    // MARK: - Views
    private var abTestSection: some View {
        Section {
            Toggle("Create Account Test", isOn: $viewModel.createAccountTest)
                .onChange(of: viewModel.createAccountTest, viewModel.handleCreateAccountChange)
            
            Toggle("Onboarding Community Test", isOn: $viewModel.onboardingCommunityTest)
                .onChange(of: viewModel.onboardingCommunityTest, viewModel.handleOnboardingCommunityChange)
            
            Picker("Category Row Test", selection: $viewModel.categoryRowTest) {
                ForEach(CategoryRowTestOption.allCases) { option in
                    Text(option.rawValue)
                        .tag(option)
                }
            }
            .onChange(of: viewModel.categoryRowTest, viewModel.handleCategoryRowChange)
            
            Picker("Paywall Test", selection: $viewModel.paywallTest) {
                ForEach(PaywallTestOption.allCases) { option in
                    Text(option.rawValue)
                        .tag(option)
                }
            }
            .onChange(of: viewModel.paywallTest, viewModel.handlePaywallTestChange)
        } header: {
            Text("AB Tests")
        }
        .font(.caption)
    }
    
    private var authSection: some View {
        Section {
            let array = viewModel.getAuthParameters()
            ForEach(array, id: \.key) { item in
                viewModel.itemRow(item: item)
            }
        } header: {
            Text("Auth Info")
        }
    }
    
    private var userSection: some View {
        Section {
            let array = viewModel.getCurrentUserParameters()
            ForEach(array, id: \.key) { item in
                viewModel.itemRow(item: item)
            }
        } header: {
            Text("User Info")
        }
    }
    
    private var deviceSection: some View {
        Section {
            let array = AppInfo.eventParameters.asAlphabeticalArray
            ForEach(array, id: \.key) { item in
                viewModel.itemRow(item: item)
            }
        } header: {
            Text("Device Info")
        }
    }
    
    private var backButtonView: some View {
        Image(systemName: "xmark")
            .font(.title2)
            .fontWeight(.black)
            .anyButton {
                dismiss()
            }
    }
}

#Preview {
    DevSettingsView(viewModel: DevSettingsViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)))
        .previewEnvironment()
}
