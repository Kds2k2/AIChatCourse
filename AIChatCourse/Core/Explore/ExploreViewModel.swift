//
//  ExploreViewModel.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 10.03.2026.
//

import SwiftUI

@MainActor
protocol ExploreInteractor {
    var auth: UserAuthInfo? { get }
    var categoryRowTest: CategoryRowTestOption { get }
    var createAccountTest: Bool { get }
    
    func trackEvent(event: LoggableEvent)
    func getFeaturedAvatars() async throws -> [AvatarModel]
    func getPopularAvatars() async throws -> [AvatarModel]
    func canRequestAuthorization() async -> Bool
    func schedulePushNotificationForTheNextWeek()
}

extension CoreInteractor: ExploreInteractor { }

@Observable
@MainActor
class ExploreViewModel {
    let interactor: ExploreInteractor
    
    private(set) var categories: [CharacterOption] = CharacterOption.allCases
    private(set) var featuredAvatars: [AvatarModel] = []
    private(set) var popularAvatars: [AvatarModel] = []
    
    private(set) var isLoadingFeatured: Bool = true
    private(set) var isLoadingPopular: Bool = true
    private(set) var showPushNotificationButton: Bool = false
    
    var path: [TabBarPathOption] = []
    var showPushNotificationModal: Bool = false
    var showAppleProvider: Bool = false
    var showDevSettings: Bool = false
    
    var showDevSettingsButton: Bool {
        #if DEV || MOCK
            return true
        #else
            return false
        #endif
    }
    
    var categoryRowTest: CategoryRowTestOption {
        interactor.categoryRowTest
    }
    
    var createAccountTest: Bool {
        interactor.createAccountTest
    }
    
    init(interactor: ExploreInteractor) {
        self.interactor = interactor
    }
    
    // MARK: - Loading
    func loadFeatureAvatars() async {
        guard featuredAvatars.isEmpty else { return }
        interactor.trackEvent(event: Event.loadFeatureAvatarsStart)
        isLoadingFeatured = true
        
        do {
            featuredAvatars = try await interactor.getFeaturedAvatars()
            interactor.trackEvent(event: Event.loadFeatureAvatarsSuccess)
        } catch {
            interactor.trackEvent(event: Event.loadFeatureAvatarsFail(error: error))
        }
        
        isLoadingFeatured = false
    }

    func loadPopularAvatars() async {
        guard popularAvatars.isEmpty else { return }
        interactor.trackEvent(event: Event.loadPopularAvatarsStart)
        isLoadingPopular = true
        
        do {
            popularAvatars = try await interactor.getPopularAvatars()
            interactor.trackEvent(event: Event.loadPopularAvatarsSuccess)
        } catch {
            interactor.trackEvent(event: Event.loadPopularAvatarsFail(error: error))
        }
        
        isLoadingPopular = false
    }
    
    func handleDeepLink(url: URL) {
        interactor.trackEvent(event: Event.deepLinkStart(url: url))
        guard let componets = URLComponents(url: url, resolvingAgainstBaseURL: false), let query = componets.queryItems else {
            print("NO QUERY ITEMS")
            interactor.trackEvent(event: Event.deepLinkEmpty(url: url))
            return
        }
        
        for queryItem in query {
            if queryItem.name == "category", let value = queryItem.value, let category = CharacterOption(rawValue: value) {
                let imageName = Constants.randomImage
                path.append(.category(category: category, imageName: imageName))
                interactor.trackEvent(event: Event.deepLinkCategory(category: category))
                return
            }
        }
        
        interactor.trackEvent(event: Event.deepLinkUnknown(url: url))
    }
    
    func handleShowPushNotificationButton() async {
        showPushNotificationButton = await interactor.canRequestAuthorization()
    }
    
    func schedulePushNotifications() {
        interactor.schedulePushNotificationForTheNextWeek()
    }
    
    func showCreateAccountIfNeeded() {
        Task {
            try? await Task.sleep(for: .seconds(1))
            
            guard
                interactor.auth?.isAnonymous == true &&
                interactor.createAccountTest == true
            else {
                return
            }
            
            showAppleProvider = true
        }
    }
    
    // MARK: - Actions
    func onTryAgainPressed() {
        interactor.trackEvent(event: Event.tryAgainButtonPressed)
        Task {
            await loadFeatureAvatars()
        }
        Task {
            await loadPopularAvatars()
        }
    }
    
    func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
        interactor.trackEvent(event: Event.avatarPressed(avatar: avatar))
    }
    
    func onCategoryPressed(category: CharacterOption, imageName: String) {
        path.append(.category(category: category, imageName: imageName))
        interactor.trackEvent(event: Event.categoryPressed(categoty: category))
    }

    func onDevSettingsPressed() {
        showDevSettings = true
        interactor.trackEvent(event: Event.devSettingsButtonPressed)
    }
    
    func onPushNotificationButtonPressed() {
        showPushNotificationModal = true
        interactor.trackEvent(event: Event.pushNotificationStart)
    }
    
    func onEnablePushNotificationModalPressed() {
        showPushNotificationModal = false
        
        Task {
            let isAuthorized = try await LocalNotifications.requestAuthorization()
            interactor.trackEvent(event: Event.pushNotificationEnable(isAuthorized: isAuthorized))
            await handleShowPushNotificationButton()
        }
    }
    
    func onCancelPushNotificationModalPressed() {
        showPushNotificationModal = false
        interactor.trackEvent(event: Event.pushNotificationCancel)
    }
    
    // MARK: - Logs
    enum Event: LoggableEvent {
        case loadFeatureAvatarsStart, loadFeatureAvatarsSuccess, loadFeatureAvatarsFail(error: Error)
        case loadPopularAvatarsStart, loadPopularAvatarsSuccess, loadPopularAvatarsFail(error: Error)
        case avatarPressed(avatar: AvatarModel), categoryPressed(categoty: CharacterOption)
        case tryAgainButtonPressed, devSettingsButtonPressed
        case pushNotificationStart, pushNotificationEnable(isAuthorized: Bool), pushNotificationCancel
        case deepLinkStart(url: URL), deepLinkEmpty(url: URL), deepLinkCategory(category: CharacterOption), deepLinkUnknown(url: URL)
        
        static var screenName: String = "ExploreView"
        
        var eventName: String {
            switch self {
            case .loadFeatureAvatarsStart:                   return "\(Event.screenName)_LoadFeatureAvatars_Start"
            case .loadFeatureAvatarsSuccess:                 return "\(Event.screenName)_LoadFeatureAvatars_Success"
            case .loadFeatureAvatarsFail:                    return "\(Event.screenName)_LoadFeatureAvatars_Fail"
            case .loadPopularAvatarsStart:                   return "\(Event.screenName)_LoadPopularAvatars_Start"
            case .loadPopularAvatarsSuccess:                 return "\(Event.screenName)_LoadPopularAvatars_Success"
            case .loadPopularAvatarsFail:                    return "\(Event.screenName)_LoadPopularAvatars_Fail"
            case .avatarPressed:                             return "\(Event.screenName)_Avatar_Pressed"
            case .categoryPressed:                           return "\(Event.screenName)_Category_Pressed"
            case .tryAgainButtonPressed:                     return "\(Event.screenName)_TryAgainButton_Pressed"
            case .devSettingsButtonPressed:                  return "\(Event.screenName)_DevSettingsButton_Pressed"
            case .pushNotificationStart:                     return "\(Event.screenName)_PushNotification_Start"
            case .pushNotificationEnable:                    return "\(Event.screenName)_PushNotification_Enable"
            case .pushNotificationCancel:                    return "\(Event.screenName)_PushNotification_Cancel"
            case .deepLinkStart:                             return "\(Event.screenName)_DeepLink_Start"
            case .deepLinkEmpty:                             return "\(Event.screenName)_DeepLink_Empty"
            case .deepLinkCategory:                          return "\(Event.screenName)_DeepLink_Category"
            case .deepLinkUnknown:                           return "\(Event.screenName)_DeepLink_Unknown"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadFeatureAvatarsFail(error: let error), .loadPopularAvatarsFail(error: let error):
                return error.eventParameters
            case .avatarPressed(avatar: let avatar):
                return avatar.eventParameters
            case .categoryPressed(categoty: let category), .deepLinkCategory(category: let category):
                return ["category": category.rawValue]
            case .pushNotificationEnable(isAuthorized: let isAuthorized):
                return ["is_authorized": isAuthorized]
            case .deepLinkStart(url: let url), .deepLinkEmpty(url: let url), .deepLinkUnknown(url: let url):
                return ["deep_link_url": url.absoluteString]
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadFeatureAvatarsFail, .loadPopularAvatarsFail:
                    .severe
            default:
                    .analytic
            }
        }
    }
}
