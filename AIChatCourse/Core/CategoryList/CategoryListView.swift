//
//  CategoryListView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 06.01.2026.
//

import SwiftUI
import SDWebImageSwiftUI

struct CategoryListView: View {
    
    @Environment(AvatarManager.self) private var avatarManager
        
    @Binding var path: [NavigationPathOption]
    var category: CharacterOption = .alien
    var imageName: String = Constants.randomImage
    @State private var avatars: [AvatarModel] = []
    @State private var isLoading: Bool = true
    
    @State private var showAlert: AnyAppAlert?
    
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
            
            if isLoading {
                ProgressView()
                    .padding(40)
                    .frame(maxWidth: .infinity)
                    .removeListRowFormatting()
                    .listRowSeparator(.hidden)
            } else if avatars.isEmpty {
                Text("No avatars found.")
                    .frame(maxWidth: .infinity)
                    .padding(40)
                    .foregroundStyle(.secondary)
                    .removeListRowFormatting()
                    .listRowSeparator(.hidden)
            } else {
                ForEach(avatars, id: \.self) { avatar in
                    CustomListCellView(
                        imageName: avatar.profileImageName,
                        title: avatar.name,
                        subtitle: avatar.characterDescription
                    )
                    .anyButton(.highlight) {
                        onAvatarPressed(avatar: avatar)
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
            await loadAvatarsForCategory()
        }
        .showCustomAlert(alert: $showAlert)
    }
    
    private func loadAvatarsForCategory() async {
        isLoading = true
        
        do {
            avatars = try await avatarManager.getAvatarsForCategory(category: category)
        } catch {
            showAlert = AnyAppAlert(error: error)
        }
        
        isLoading = false
    }
    
    private func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId))
    }
}

#Preview("Has data") {
    CategoryListView(path: .constant([]))
        .environment(AvatarManager(remote: MockAvatarService()))
}

#Preview("No data") {
    CategoryListView(path: .constant([]))
        .environment(AvatarManager(remote: MockAvatarService(avatars: [])))
}

#Preview("Slow loading") {
    CategoryListView(path: .constant([]))
        .environment(AvatarManager(remote: MockAvatarService(delay: 10)))
}

#Preview("Error loading") {
    CategoryListView(path: .constant([]))
        .environment(AvatarManager(remote: MockAvatarService(delay: 5, showError: true)))
}
