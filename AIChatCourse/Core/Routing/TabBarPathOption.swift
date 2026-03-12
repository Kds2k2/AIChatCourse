//
//  NavigationPathOption.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 06.01.2026.
//

import SwiftUI
import Foundation

enum TabBarPathOption: Hashable {
    case chat(avatarId: String, chat: ChatModel?)
    case category(category: CharacterOption, imageName: String)
}

struct NavigationDestinationForTabBarModuleViewModifier: ViewModifier {
    @Environment(DependencyContainer.self) private var container
    let path: Binding<[TabBarPathOption]>
    
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: TabBarPathOption.self) { newValue in
                switch newValue {
                case .chat(avatarId: let avatarId, chat: let chat):
                    ChatView(
                        viewModel: ChatViewModel(interactor: CoreInteractor(container: container)),
                        chat: chat,
                        avatarId: avatarId)
                case .category(category: let category, imageName: let imageName):
                    CategoryListView(
                        viewModel: CategoryListViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ),
                        path: path,
                        category: category,
                        imageName: imageName
                    )
                }
            }
    }
}

extension View {
    func navigationDestinationForTabBarModule(path: Binding<[TabBarPathOption]>) -> some View {
        modifier(NavigationDestinationForTabBarModuleViewModifier(path: path))
    }
}
