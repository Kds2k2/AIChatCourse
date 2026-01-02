//
//  ExploreView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 31.12.2025.
//

import SwiftUI

struct ExploreView: View {
    
    let avatar = AvatarModel.mock
    
    var body: some View {
        NavigationStack {
            HeroCellView(
                title: avatar.name,
                subtitle: avatar.characterDescription,
                imageName: avatar.profileImageName,
                lineWidth: 1.0
            )
            .frame(height: 200)
            .navigationTitle("Explore")
        }
    }
}

#Preview {
    ExploreView()
}
