//
//  CategoryListView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 06.01.2026.
//

import SwiftUI
import SDWebImageSwiftUI

@Observable
@MainActor
class CategoryListViewModel {
    
    let avatarManager: AvatarManager
    let logManager: LogManager
    
    private(set) var avatars: [AvatarModel] = []
    private(set) var isLoading: Bool = true
    
    var showAlert: AnyAppAlert?
    
    init(container: DependencyContainer) {
        self.avatarManager = container.resolve(AvatarManager.self)!
        self.logManager = container.resolve(LogManager.self)!
    }
    
    func loadAvatarsForCategory(category: CharacterOption) async {
        logManager.trackEvent(event: Event.loadAvatarsStart)
        isLoading = true
        
        do {
            avatars = try await avatarManager.getAvatarsForCategory(category: category)
            logManager.trackEvent(event: Event.loadAvatarsSuccess)
        } catch {
            showAlert = AnyAppAlert(error: error)
            logManager.trackEvent(event: Event.loadAvatarsFail(error: error))
        }
        
        isLoading = false
    }
    
    func onAvatarPressed(avatar: AvatarModel, path: Binding<[NavigationPathOption]>) {
        path.wrappedValue.append(.chat(avatarId: avatar.avatarId, chat: nil))
        logManager.trackEvent(event: Event.onAvatarPressed(avatar: avatar))
    }
    
    enum Event: LoggableEvent {
        case loadAvatarsStart
        case loadAvatarsSuccess
        case loadAvatarsFail(error: Error)
        case onAvatarPressed(avatar: AvatarModel)
        
        static let screenName = "CategoryListView"
        
        var eventName: String {
            switch self {
            case .loadAvatarsStart: "\(Event.screenName)_LoadAvatars_Start"
            case .loadAvatarsSuccess: "\(Event.screenName)_LoadAvatars_Success"
            case .loadAvatarsFail: "\(Event.screenName)_LoadAvatars_Fail"
            case .onAvatarPressed: "\(Event.screenName)_OnAvatarPressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadAvatarsFail(error: let error):
                return error.eventParameters
            case .onAvatarPressed(avatar: let avatar):
                return avatar.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadAvatarsFail:
                .severe
            default:
                .analytic
            }
        }
    }
}

struct CategoryListView: View {
    
    @State var viewModel: CategoryListViewModel

    @Binding var path: [NavigationPathOption]
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
    
    return CategoryListView(viewModel: CategoryListViewModel(container: container), path: .constant([]))
        .previewEnvironment()
}

#Preview("No data") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(remote: MockAvatarService(avatars: [])))
    
    return CategoryListView(viewModel: CategoryListViewModel(container: container), path: .constant([]))
        .previewEnvironment()
}

#Preview("Slow loading") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(remote: MockAvatarService(delay: 10)))
    
    return CategoryListView(viewModel: CategoryListViewModel(container: container), path: .constant([]))
        .previewEnvironment()
}

#Preview("Error loading") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(remote: MockAvatarService(delay: 5, showError: true)))
    
    return CategoryListView(viewModel: CategoryListViewModel(container: container), path: .constant([]))
        .previewEnvironment()
}
