//
//  OnboardingCommunityViewModel.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 12.03.2026.
//

import SwiftUI

@MainActor
protocol OnboardingCommunityInteractor {
    
}

extension CoreInteractor: OnboardingCommunityInteractor { }

@Observable
@MainActor
class OnboardingCommunityViewModel {
    let interactor: OnboardingCommunityInteractor
    
    init(interactor: OnboardingCommunityInteractor) {
        self.interactor = interactor
    }
    
    func onContinuePressed(path: Binding<[OnboardingPathOption]>) {
        path.wrappedValue.append(.color)
    }
}
