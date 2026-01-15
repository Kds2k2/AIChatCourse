//
//  ProfileView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 31.12.2025.
//

import SwiftUI

struct ProfileView: View {

    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(AvatarManager.self) private var avatarManager
    
    @State private var currentUser: UserModel?
    @State private var myAvatars: [AvatarModel] = []
    @State private var isLoading: Bool = true
    
    @State private var showCreateAvatarView: Bool = false
    @State private var showSettingsView: Bool = false
    @State private var showAlert: AnyAppAlert?
    
    @State private var path: [NavigationPathOption] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                myInfoSection
                myAvatarsSection
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    settingsButton
                }
            }
            .navigationDestinationForCoreModule(path: $path)
        }
        .showCustomAlert(alert: $showAlert)
        .sheet(isPresented: $showSettingsView) {
            SettingsView()
        }
        .fullScreenCover(isPresented: $showCreateAvatarView, onDismiss: {
            Task { await loadData() }
        }, content: {
            CreateAvatarView()
        })
        .task {
            await loadData()
        }
    }
    
    private func loadData() async {
        self.currentUser = userManager.currentUser
        
        do {
            let uid = try authManager.getAuthId()
            myAvatars = try await avatarManager.getAvatarsForUser(userId: uid)
        } catch {
            print("Error while fetching user avatars\(error)")
        }

        isLoading = false
    }

    private var myInfoSection: some View {
        Section {
            ZStack {
                Circle()
                    .fill(currentUser?.profileColorCalculated ?? .accent)
            }
            .frame(width: 100, height: 100)
            .frame(maxWidth: .infinity)
            .removeListRowFormatting()
        }
    }
    
    private var myAvatarsSection: some View {
        Section {
            if myAvatars.isEmpty {
                Group {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Click + to create an avatar")
                    }
                }
                .padding(50)
                .frame(maxWidth: .infinity)
                .font(.body)
                .foregroundStyle(.secondary)
                .removeListRowFormatting()
            } else {
                ForEach(myAvatars, id: \.self) { avatar in
                    CustomListCellView(
                        imageName: avatar.profileImageName,
                        title: avatar.name,
                        subtitle: nil
                    )
                    .anyButton(.highlight, action: {
                        onAvatarPressed(avatar: avatar)
                    })
                    .removeListRowFormatting()
                }
                .onDelete { indexSet in
                    onDeleteAvatar(indexSet)
                }
            }
        } header: {
            HStack(spacing: 0) {
                Text("My Avatars")
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .font(.title)
                    .foregroundStyle(.accent)
                    .anyButton {
                        onCreateAvatarButtonPressed()
                    }
            }
        }
    }
    
    private var settingsButton: some View {
        Button {
            onSettingsButtonPressed()
        } label: {
            Image(systemName: "gear")
                .font(.headline)
        }
        .tint(.accent)
    }

    private func onCreateAvatarButtonPressed() {
        showCreateAvatarView = true
    }
    
    private func onSettingsButtonPressed() {
        showSettingsView = true
    }
    
    private func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId))
    }
    
    private func onDeleteAvatar(_ indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let avatar = myAvatars[index]
        
        Task {
            do {
                try await avatarManager.removeAuthorIdFromAvatar(avatarId: avatar.id)
                myAvatars.remove(at: index)
            } catch {
                showAlert = AnyAppAlert(title: "Unable to delete avatar.", subtitle: "Please try again.")
            }
        }
        
        myAvatars.remove(at: index)
    }
}

#Preview {
    ProfileView()
        .previewEnvironment()
}
