//
//  CategoryListView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 06.01.2026.
//

import SwiftUI
import SDWebImageSwiftUI

struct CategoryListView: View {
    
    @Binding var path: [NavigationPathOption]
    var category: CharacterOption = .alien
    var imageName: String = Constants.randomImage
    @State private var avatars: [AvatarModel] = AvatarModel.mocks + AvatarModel.mocks + AvatarModel.mocks
    
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
        .listStyle(.plain)
        .coordinateSpace(name: "scroll")
        .scrollIndicators(.hidden)
        .ignoresSafeArea()
    }
    
    private func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId))
    }
}

#Preview {
    CategoryListView(path: .constant([]))
}
