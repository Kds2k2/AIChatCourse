//
//  OnboardingPathOption.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 12.03.2026.
//

import SwiftUI
import Foundation

enum OnboardingPathOption: Hashable {
    case intro
    case community, color
    case completed(color: Color)
}

struct NavigationDestinationForOnboardingModuleViewModifier: ViewModifier {
    @Environment(DependencyContainer.self) private var container
    let path: Binding<[OnboardingPathOption]>
    
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: OnboardingPathOption.self) { newValue in
                switch newValue {
                case .intro:
                    OnboardingIntroView(viewModel: .init(interactor: CoreInteractor(container: container)), path: path)
                case .community:
                    OnboardingCommunityView(viewModel: .init(interactor: CoreInteractor(container: container)), path: path)
                case .color:
                    OnboardingColorView(viewModel: .init(interactor: CoreInteractor(container: container)), path: path)
                case .completed(color: let color):
                    OnboardingCompletedView(viewModel: .init(interactor: CoreInteractor(container: container)), selectedColor: color)
                }
            }
    }
}

extension View {
    func navigationDestinationForOnboardingModule(path: Binding<[OnboardingPathOption]>) -> some View {
        modifier(NavigationDestinationForOnboardingModuleViewModifier(path: path))
    }
}
