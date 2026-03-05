//
//  ProfileView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 31.12.2025.
//

import SwiftUI

@MainActor
struct ProductionProfileInteractor: ProfileInteractor {
    
    let authManager: AuthManager
    let userManager: UserManager
    let avatarManager: AvatarManager
    let logManager: LogManager
    
    init(container: DependencyContainer) {
        self.authManager = container.resolve(AuthManager.self)!
        self.userManager = container.resolve(UserManager.self)!
        self.avatarManager = container.resolve(AvatarManager.self)!
        self.logManager = container.resolve(LogManager.self)!
    }
    
    var currentUser: UserModel? { userManager.currentUser }
    
    func getAvatarsForUser(userId: String) async throws -> [AvatarModel] {
        try await avatarManager.getAvatarsForUser(userId: userId)
    }
    
    func removeAuthorIdFromAvatar(avatarId: String) async throws {
        try await avatarManager.removeAuthorIdFromAvatar(avatarId: avatarId)
    }
    
    func trackEvent(event: any LoggableEvent) {
        logManager.trackEvent(event: event)
    }
    
    func getAuthId() throws -> String {
        try authManager.getAuthId()
    }
}

@MainActor
protocol ProfileInteractor {
    var currentUser: UserModel? { get }
    
    func getAvatarsForUser(userId: String) async throws -> [AvatarModel]
    func removeAuthorIdFromAvatar(avatarId: String) async throws
    func trackEvent(event: LoggableEvent)
    func getAuthId() throws -> String
}

@Observable
@MainActor
class ProfileViewModel {
    
    private let interactor: ProfileInteractor
    
    private(set) var currentUser: UserModel?
    private(set) var myAvatars: [AvatarModel] = []
    private(set) var isLoading: Bool = true
    
    var showCreateAvatarView: Bool = false
    var showSettingsView: Bool = false
    var showAlert: AnyAppAlert?
    var path: [NavigationPathOption] = []
    
    init(interactor: ProfileInteractor) {
        self.interactor = interactor
    }
    
    // MARK: - Loading
    func loadData() async {
        interactor.trackEvent(event: Event.loadAvatarsStart)
        self.currentUser = interactor.currentUser
        
        do {
            let uid = try interactor.getAuthId()
            myAvatars = try await interactor.getAvatarsForUser(userId: uid)
            interactor.trackEvent(event: Event.loadAvatarsSuccess)
        } catch {
            interactor.trackEvent(event: Event.loadAvatarsFail(error: error))
        }

        isLoading = false
    }
    
    // MARK: - Actions
    func onCreateAvatarButtonPressed() {
        showCreateAvatarView = true
        interactor.trackEvent(event: Event.createAvatarButtonPressed)
    }
    
    func onSettingsButtonPressed() {
        showSettingsView = true
        interactor.trackEvent(event: Event.settingsButtonPressed)
    }
    
    func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
        interactor.trackEvent(event: Event.avatarPressed(avatar: avatar))
    }
    
    func onDeleteAvatar(_ indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let avatar = myAvatars[index]
        interactor.trackEvent(event: Event.deleteAvatarStart(avatar: avatar))
        
        Task {
            do {
                try await interactor.removeAuthorIdFromAvatar(avatarId: avatar.id)
                myAvatars.remove(at: index)
                interactor.trackEvent(event: Event.deleteAvatarSuccess(avatar: avatar))
            } catch {
                showAlert = AnyAppAlert(title: "Unable to delete avatar.", subtitle: "Please try again.")
                interactor.trackEvent(event: Event.deleteAvatarFail(error: error))
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
    ProfileView(viewModel: .init(interactor: ProductionProfileInteractor(container: DevPreview.shared.container)))
        .previewEnvironment()
}
