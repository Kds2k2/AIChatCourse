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
    @Environment(LogManager.self) private var logManager
    
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
        .screenAppearAnalytics(name: "ProfileView")
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
    
    // MARK: - Loading
    private func loadData() async {
        logManager.trackEvent(event: Event.loadAvatarsStart)
        self.currentUser = userManager.currentUser
        
        do {
            let uid = try authManager.getAuthId()
            myAvatars = try await avatarManager.getAvatarsForUser(userId: uid)
            logManager.trackEvent(event: Event.loadAvatarsSuccess)
        } catch {
            logManager.trackEvent(event: Event.loadAvatarsFail(error: error))
        }

        isLoading = false
    }

    // MARK: - Views
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

    // MARK: - Actions
    private func onCreateAvatarButtonPressed() {
        showCreateAvatarView = true
        logManager.trackEvent(event: Event.createAvatarButtonPressed)
    }
    
    private func onSettingsButtonPressed() {
        showSettingsView = true
        logManager.trackEvent(event: Event.settingsButtonPressed)
    }
    
    private func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
        logManager.trackEvent(event: Event.avatarPressed(avatar: avatar))
    }
    
    private func onDeleteAvatar(_ indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let avatar = myAvatars[index]
        logManager.trackEvent(event: Event.deleteAvatarStart(avatar: avatar))
        
        Task {
            do {
                try await avatarManager.removeAuthorIdFromAvatar(avatarId: avatar.id)
                myAvatars.remove(at: index)
                logManager.trackEvent(event: Event.deleteAvatarSuccess(avatar: avatar))
            } catch {
                showAlert = AnyAppAlert(title: "Unable to delete avatar.", subtitle: "Please try again.")
                logManager.trackEvent(event: Event.deleteAvatarFail(error: error))
            }
        }
        
        myAvatars.remove(at: index)
    }
    
    // MARK: - Logs
    enum Event: LoggableEvent {
        case loadAvatarsStart, loadAvatarsSuccess, loadAvatarsFail(error: Error)
        case createAvatarButtonPressed, settingsButtonPressed
        case avatarPressed(avatar: AvatarModel)
        case deleteAvatarStart(avatar: AvatarModel), deleteAvatarSuccess(avatar: AvatarModel), deleteAvatarFail(error: Error)
        
        static var screenName: String = "ProfileView"
        
        var eventName: String {
            switch self {
            case .loadAvatarsStart:                         return "\(Event.screenName)_LoadAvatars_Start"
            case .loadAvatarsSuccess:                       return "\(Event.screenName)_LoadAvatars_Success"
            case .loadAvatarsFail:                          return "\(Event.screenName)_LoadAvatars_Fail"
            case .createAvatarButtonPressed:                return "\(Event.screenName)_CreateAvatarButton_Pressed"
            case .settingsButtonPressed:                    return "\(Event.screenName)_SettingsButton_Pressed"
            case .avatarPressed:                            return "\(Event.screenName)_Avatar_Pressed"
            case .deleteAvatarStart:                        return "\(Event.screenName)_DeleteAvatar_Start"
            case .deleteAvatarSuccess:                      return "\(Event.screenName)_DeleteAvatar_Success"
            case .deleteAvatarFail:                         return "\(Event.screenName)_DeleteAvatar_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadAvatarsFail(error: let error), .deleteAvatarFail(error: let error):
                return error.eventParameters
            case .avatarPressed(avatar: let avatar), .deleteAvatarStart(avatar: let avatar), .deleteAvatarSuccess(avatar: let avatar):
                return avatar.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadAvatarsFail, .deleteAvatarFail:
                    .severe
            default:
                    .analytic
            }
        }
    }
}

#Preview {
    ProfileView()
        .previewEnvironment()
}
