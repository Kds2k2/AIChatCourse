//
//  ProfileView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 31.12.2025.
//

import SwiftUI

@Observable
@MainActor
class ProfileViewModel {
    
    let authManager: AuthManager
    let userManager: UserManager
    let avatarManager: AvatarManager
    let logManager: LogManager
    
    private(set) var currentUser: UserModel?
    private(set) var myAvatars: [AvatarModel] = []
    private(set) var isLoading: Bool = true
    
    var showCreateAvatarView: Bool = false
    var showSettingsView: Bool = false
    var showAlert: AnyAppAlert?
    var path: [NavigationPathOption] = []
    
    init(container: DependencyContainer) {
        self.authManager = container.resolve(AuthManager.self)!
        self.userManager = container.resolve(UserManager.self)!
        self.avatarManager = container.resolve(AvatarManager.self)!
        self.logManager = container.resolve(LogManager.self)!
    }
    
    // MARK: - Loading
    func loadData() async {
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
    
    // MARK: - Actions
    func onCreateAvatarButtonPressed() {
        showCreateAvatarView = true
        logManager.trackEvent(event: Event.createAvatarButtonPressed)
    }
    
    func onSettingsButtonPressed() {
        showSettingsView = true
        logManager.trackEvent(event: Event.settingsButtonPressed)
    }
    
    func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
        logManager.trackEvent(event: Event.avatarPressed(avatar: avatar))
    }
    
    func onDeleteAvatar(_ indexSet: IndexSet) {
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

struct ProfileView: View {

    @Environment(DependencyContainer.self) private var container
    @State var viewModel: ProfileViewModel
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
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
            .navigationDestinationForCoreModule(path: $viewModel.path)
        }
        .showCustomAlert(alert: $viewModel.showAlert)
        .screenAppearAnalytics(name: "ProfileView")
        .sheet(isPresented: $viewModel.showSettingsView) {
            SettingsView()
        }
        .fullScreenCover(
            isPresented: $viewModel.showCreateAvatarView,
            onDismiss: {
                Task { await viewModel.loadData() }
            },
            content: {
                CreateAvatarView(viewModel: .init(container: container))
        })
        .task {
            await viewModel.loadData()
        }
    }

    // MARK: - Views
    private var myInfoSection: some View {
        Section {
            ZStack {
                Circle()
                    .fill(viewModel.currentUser?.profileColorCalculated ?? .accent)
            }
            .frame(width: 100, height: 100)
            .frame(maxWidth: .infinity)
            .removeListRowFormatting()
        }
    }
    
    private var myAvatarsSection: some View {
        Section {
            if viewModel.myAvatars.isEmpty {
                Group {
                    if viewModel.isLoading {
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
                ForEach(viewModel.myAvatars, id: \.self) { avatar in
                    CustomListCellView(
                        imageName: avatar.profileImageName,
                        title: avatar.name,
                        subtitle: nil
                    )
                    .anyButton(.highlight, action: {
                        viewModel.onAvatarPressed(avatar: avatar)
                    })
                    .removeListRowFormatting()
                }
                .onDelete { indexSet in
                    viewModel.onDeleteAvatar(indexSet)
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
                        viewModel.onCreateAvatarButtonPressed()
                    }
            }
        }
    }
    
    private var settingsButton: some View {
        Button {
            viewModel.onSettingsButtonPressed()
        } label: {
            Image(systemName: "gear")
                .font(.headline)
        }
        .tint(.accent)
    }
}

#Preview {
    ProfileView(viewModel: .init(container: DevPreview.shared.container))
        .previewEnvironment()
}
