//
//  CategoryListView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 06.01.2026.
//

import SwiftUI
import SDWebImageSwiftUI

struct CategoryListView: View {
    
    @State var viewModel: CategoryListViewModel

    @Binding var path: [TabBarPathOption]
    var category: CharacterOption = .alien
    var imageName: String = Constants.randomImage
    
    var body: some View {
        List {
            CategoryCellView(
                title: category.rawValue.capitalized,
                imageName: imageName,
                font: .title,
                cornerRadius: 0.0,
                lineWidth: 0.0,
                contentMode: .fill
            )
            .removeListRowFormatting()
            .listRowSeparator(.hidden, edges: .top)
            .stretchy()
            
            if viewModel.isLoading {
                ProgressView()
                    .padding(40)
                    .frame(maxWidth: .infinity)
                    .removeListRowFormatting()
                    .listRowSeparator(.hidden)
            } else if viewModel.avatars.isEmpty {
                Text("No avatars found.")
                    .frame(maxWidth: .infinity)
                    .padding(40)
                    .foregroundStyle(.secondary)
                    .removeListRowFormatting()
                    .listRowSeparator(.hidden)
            } else {
                ForEach(viewModel.avatars, id: \.self) { avatar in
                    CustomListCellView(
                        imageName: avatar.profileImageName,
                        title: avatar.name,
                        subtitle: avatar.characterDescription
                    )
                    .anyButton(.highlight) {
                        viewModel.onAvatarPressed(avatar: avatar, path: $path)
                    }
                    .removeListRowFormatting()
                }
            }
        }
        .listStyle(.plain)
        .coordinateSpace(name: "scroll")
        .scrollIndicators(.hidden)
        .ignoresSafeArea()
        .task {
            await viewModel.loadAvatarsForCategory(category: category)
        }
        .showCustomAlert(alert: $viewModel.showAlert)
        .screenAppearAnalytics(name: "CategoryListView")
    }
}

#Preview("Has data") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(remote: MockAvatarService()))
    
    return CategoryListView(viewModel: CategoryListViewModel(interactor: CoreInteractor(container: container)), path: .constant([]))
        .previewEnvironment()
}

#Preview("No data") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(remote: MockAvatarService(avatars: [])))
    
    return CategoryListView(viewModel: CategoryListViewModel(interactor: CoreInteractor(container: container)), path: .constant([]))
        .previewEnvironment()
}

#Preview("Slow loading") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(remote: MockAvatarService(delay: 10)))
    
    return CategoryListView(viewModel: CategoryListViewModel(interactor: CoreInteractor(container: container)), path: .constant([]))
        .previewEnvironment()
}

#Preview("Error loading") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(remote: MockAvatarService(delay: 5, showError: true)))
    
    return CategoryListView(viewModel: CategoryListViewModel(interactor: CoreInteractor(container: container)), path: .constant([]))
        .previewEnvironment()
}
