//
//  TabBarView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 31.12.2025.
//

import SwiftUI

struct TabBarView: View {
    
    @Environment(DependencyContainer.self) private var container
    
    var body: some View {
        TabView {
            Tab("Explore", systemImage: "eyes") {
                ExploreView(viewModel: ExploreViewModel(interactor: CoreInteractor(container: container)))
            }

            Tab("Chats", systemImage: "bubble.left.and.bubble.right.fill") {
                ChatsView(viewModel: ChatsViewModel(interactor: CoreInteractor(container: container)))
            }

            Tab("Profile", systemImage: "person.fill") {
                ProfileView(viewModel: ProfileViewModel(interactor: CoreInteractor(container: container)))
            }
        }
    }
}

#Preview {
    TabBarView()
        .previewEnvironment()
}
