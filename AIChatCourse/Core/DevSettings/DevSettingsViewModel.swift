//
//  DevSettingsViewModel.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 11.03.2026.
//

import SwiftUI

@MainActor
protocol DevSettingsInteractor {
    var activeTests: ActiveABTests { get }
    var auth: UserAuthInfo? { get }
    var currentUser: UserModel? { get }
    
    func override(updateTests: ActiveABTests) throws
}

extension CoreInteractor: DevSettingsInteractor { }

@Observable
@MainActor
class DevSettingsViewModel {
    let interactor: DevSettingsInteractor
    
    var createAccountTest: Bool = false
    var onboardingCommunityTest: Bool = false
    var categoryRowTest: CategoryRowTestOption = .original
    var paywallTest: PaywallTestOption = .custom
    
    init(interactor: DevSettingsInteractor) {
        self.interactor = interactor
    }
    
    func loadABTests() {
        createAccountTest = interactor.activeTests.createAccountTest
        onboardingCommunityTest = interactor.activeTests.onboardingCommunityTest
        categoryRowTest = interactor.activeTests.categoryRowTest
        paywallTest = interactor.activeTests.paywallTest
    }
    
    func getAuthParameters() -> [(key: String, value: Any)] {
        interactor.auth?.eventParameters.asAlphabeticalArray ?? []
    }
    
    func getCurrentUserParameters() -> [(key: String, value: Any)] {
        interactor.currentUser?.eventParameters.asAlphabeticalArray ?? []
    }
    
    // MARK: - Actions
    func itemRow(item: (key: String, value: Any)) -> some View {
        HStack {
            Text(item.key)
            Spacer(minLength: 4)
            if let value = String.convertToStirng(item.value) {
                Text(value)
            } else {
                Text("Unknown")
            }
        }
        .font(.caption)
        .lineLimit(1)
        .minimumScaleFactor(0.3)
    }
    
    func handleCreateAccountChange(oldValue: Bool, newValue: Bool) {
        updateTest(
            property: &createAccountTest,
            newValue: newValue,
            savedValue: interactor.activeTests.createAccountTest
        ) { tests in
            tests.update(createAccountTest: newValue)
        }
    }
    
    func handleOnboardingCommunityChange(oldValue: Bool, newValue: Bool) {
        updateTest(
            property: &onboardingCommunityTest,
            newValue: newValue,
            savedValue: interactor.activeTests.onboardingCommunityTest
        ) { tests in
            tests.update(onboardingCommunityTest: newValue)
        }
    }
    
    func handleCategoryRowChange(oldValue: CategoryRowTestOption, newValue: CategoryRowTestOption) {
        updateTest(
            property: &categoryRowTest,
            newValue: newValue,
            savedValue: interactor.activeTests.categoryRowTest
        ) { tests in
            tests.update(categoryRowTest: newValue)
        }
    }
    
    func handlePaywallTestChange(oldValue: PaywallTestOption, newValue: PaywallTestOption) {
        updateTest(
            property: &paywallTest,
            newValue: newValue,
            savedValue: interactor.activeTests.paywallTest
        ) { tests in
            tests.update(paywallTest: newValue)
        }
    }
    
    private func updateTest<T: Codable & Equatable>(
        property: inout T,
        newValue: T,
        savedValue: T,
        updateAction: (inout ActiveABTests) -> Void
    ) {
        if newValue != savedValue {
            do {
                var tests = interactor.activeTests
                updateAction(&tests)
                try interactor.override(updateTests: tests)
            } catch {
                property = savedValue
            }
        }
    }
}
