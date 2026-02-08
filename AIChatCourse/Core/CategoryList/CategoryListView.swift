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
    @Environment(LogManager.self) private var logManager

    @Binding var path: [NavigationPathOption]
    var category: CharacterOption = .alien
    var imageName: String = Constants.randomImage
    @State private var avatars: [AvatarModel] = []
    @State private var isLoading: Bool = true
    
    @State private var showAlert: AnyAppAlert?
    
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
        .screenAppearAnalytics(name: "CategoryListView")
    }
    
    private func loadAvatarsForCategory() async {
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
    
    private func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
        logManager.trackEvent(event: Event.onAvatarPressed(avatar: avatar))
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
