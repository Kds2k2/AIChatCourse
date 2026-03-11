//
//  CategoryListViewModel.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 10.03.2026.
//

import SwiftUI

@MainActor
protocol CategoryListInteractor {
    func trackEvent(event: LoggableEvent)
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel]
}

extension CoreInteractor: CategoryListInteractor { }

@Observable
@MainActor
class CategoryListViewModel {
    let interactor: CategoryListInteractor
    
    init(interactor: CategoryListInteractor) {
        self.interactor = interactor
    }
    
    private(set) var avatars: [AvatarModel] = []
    private(set) var isLoading: Bool = true
    
    var showAlert: AnyAppAlert?
    
    func loadAvatarsForCategory(category: CharacterOption) async {
        interactor.trackEvent(event: Event.loadAvatarsStart)
        isLoading = true
        
        do {
            avatars = try await interactor.getAvatarsForCategory(category: category)
            interactor.trackEvent(event: Event.loadAvatarsSuccess)
        } catch {
            showAlert = AnyAppAlert(error: error)
            interactor.trackEvent(event: Event.loadAvatarsFail(error: error))
        }
        
        isLoading = false
    }
    
    func onAvatarPressed(avatar: AvatarModel, path: Binding<[NavigationPathOption]>) {
        path.wrappedValue.append(.chat(avatarId: avatar.avatarId, chat: nil))
        interactor.trackEvent(event: Event.onAvatarPressed(avatar: avatar))
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
