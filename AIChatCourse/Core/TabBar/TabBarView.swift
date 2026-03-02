//
//  TabBarView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 31.12.2025.
//

import SwiftUI

struct TabBarView: View {
    
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(LogManager.self) private var logManager
    
    var body: some View {
        TabView {
            Tab("Explore", systemImage: "eyes") {
                ExploreView()
            }

            Tab("Chats", systemImage: "bubble.left.and.bubble.right.fill") {
                ChatsView()
            }

            Tab("Profile", systemImage: "person.fill") {
                ProfileView(
                    viewModel: ProfileViewModel(
                        authManager: authManager,
                        userManager: userManager,
                        avatarManager: avatarManager,
                        logManager: logManager
                    )
                )
            }
        }
    }
}

#Preview {
    TabBarView()
}
