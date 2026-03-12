//
//  OnboardingIntroViewModel.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 12.03.2026.
//

import SwiftUI

@MainActor
protocol OnboardingIntroInteractor {
    var onboardingCommunityTest: Bool { get }
}

extension CoreInteractor: OnboardingIntroInteractor { }

@Observable
@MainActor
class OnboardingIntroViewModel {
    let interactor: OnboardingIntroInteractor
    
    init(interactor: OnboardingIntroInteractor) {
        self.interactor = interactor
    }
    
    func onContinuePressed(path: Binding<[OnboardingPathOption]>) {
        if interactor.onboardingCommunityTest {
            path.wrappedValue.append(.community)
        } else {
            path.wrappedValue.append(.color)
        }
    }
}
