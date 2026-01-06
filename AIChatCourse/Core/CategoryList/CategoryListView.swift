//
//  CategoryListView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 06.01.2026.
//

import SwiftUI

struct CategoryListView: View {
    
    var category: CharacterOption = .alien
    var imageName: String = Constants.randomImage
    @State private var avatars: [AvatarModel] = AvatarModel.mocks
    
    var body: some View {
        List {
            CategoryCellView(
                title: category.rawValue.capitalized,
                imageName: imageName,
                font: .title,
                cornerRadius: 0.0,
                lineWidth: 0.0
            )
            .removeListRowFormatting()
            
            ForEach(avatars, id: \.self) { avatar in
                CustomListCellView(
                    imageName: avatar.profileImageName,
                    title: avatar.name,
                    subtitle: avatar.characterDescription
                )
                .removeListRowFormatting()
            }
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .ignoresSafeArea()
    }
}

#Preview {
    CategoryListView()
}
