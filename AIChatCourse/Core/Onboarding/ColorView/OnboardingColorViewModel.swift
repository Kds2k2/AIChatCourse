//
//  OnboardingColorViewModel.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 12.03.2026.
//

import SwiftUI
@MainActor
protocol OnboardingColorInteractor { }

extension CoreInteractor: OnboardingColorInteractor { }

@Observable
@MainActor
class OnboardingColorViewModel {
    let interactor: OnboardingColorInteractor
    
    private(set) var selectedColor: Color?
    let profileColor: [Color] = [.red, .green, .orange, .blue, .purple, .cyan, .indigo, .pink]
    
    init(interactor: OnboardingColorInteractor) {
        self.interactor = interactor
    }
    
    func onColorPressed(color: Color) {
        selectedColor = color
    }
    
    func onContinuePressed(selectedColor: Color, path: Binding<[OnboardingPathOption]>) {
        path.wrappedValue.append(.completed(color: selectedColor))
    }
}
