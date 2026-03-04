//
//  ExploreView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 31.12.2025.
//

import SwiftUI

@Observable
@MainActor
class ExploreViewModel {
    let avatarManager: AvatarManager
    let logManager: LogManager
    let pushManager: PushManager
    let authManager: AuthManager
    let abTestManager: ABTestManager
    
    private(set) var categories: [CharacterOption] = CharacterOption.allCases
    private(set) var featuredAvatars: [AvatarModel] = []
    private(set) var popularAvatars: [AvatarModel] = []
    
    private(set) var isLoadingFeatured: Bool = true
    private(set) var isLoadingPopular: Bool = true
    private(set) var showPushNotificationButton: Bool = false
    
    var path: [NavigationPathOption] = []
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
    
    init(container: DependencyContainer) {
        self.avatarManager = container.resolve(AvatarManager.self)!
        self.logManager = container.resolve(LogManager.self)!
        self.pushManager = container.resolve(PushManager.self)!
        self.authManager = container.resolve(AuthManager.self)!
        self.abTestManager = container.resolve(ABTestManager.self)!
    }
    
    // MARK: - Loading
    func loadFeatureAvatars() async {
        guard featuredAvatars.isEmpty else { return }
        logManager.trackEvent(event: Event.loadFeatureAvatarsStart)
        isLoadingFeatured = true
        
        do {
            featuredAvatars = try await avatarManager.getFeaturedAvatars()
            logManager.trackEvent(event: Event.loadFeatureAvatarsSuccess)
        } catch {
            logManager.trackEvent(event: Event.loadFeatureAvatarsFail(error: error))
        }
        
        isLoadingFeatured = false
    }

    func loadPopularAvatars() async {
        guard popularAvatars.isEmpty else { return }
        logManager.trackEvent(event: Event.loadPopularAvatarsStart)
        isLoadingPopular = true
        
        do {
            popularAvatars = try await avatarManager.getPopularAvatars()
            logManager.trackEvent(event: Event.loadPopularAvatarsSuccess)
        } catch {
            logManager.trackEvent(event: Event.loadPopularAvatarsFail(error: error))
        }
        
        isLoadingPopular = false
    }
    
    func handleDeepLink(url: URL) {
        logManager.trackEvent(event: Event.deepLinkStart(url: url))
        guard let componets = URLComponents(url: url, resolvingAgainstBaseURL: false), let query = componets.queryItems else {
            print("NO QUERY ITEMS")
            logManager.trackEvent(event: Event.deepLinkEmpty(url: url))
            return
        }
        
        for queryItem in query {
            if queryItem.name == "category", let value = queryItem.value, let category = CharacterOption(rawValue: value) {
                let imageName = Constants.randomImage
                path.append(.category(category: category, imageName: imageName))
                logManager.trackEvent(event: Event.deepLinkCategory(category: category))
                return
            }
        }
        
        logManager.trackEvent(event: Event.deepLinkUnknown(url: url))
    }
    
    func handleShowPushNotificationButton() async {
        showPushNotificationButton = await pushManager.canRequestAuthorization()
    }
    
    func schedulePushNotifications() {
        pushManager.schedulePushNotificationForTheNextWeek()
    }
    
    func showCreateAccountIfNeeded() {
        Task {
            try? await Task.sleep(for: .seconds(1))
            
            guard
                authManager.auth?.isAnonymous == true &&
                abTestManager.activeTests.createAccountTest == true
            else {
                return
            }
            
            showAppleProvider = true
        }
    }
    
    // MARK: - Actions
    func onTryAgainPressed() {
        logManager.trackEvent(event: Event.tryAgainButtonPressed)
        Task {
            await loadFeatureAvatars()
        }
        Task {
            await loadPopularAvatars()
        }
    }
    
    func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
        logManager.trackEvent(event: Event.avatarPressed(avatar: avatar))
    }
    
    func onCategoryPressed(category: CharacterOption, imageName: String) {
        path.append(.category(category: category, imageName: imageName))
        logManager.trackEvent(event: Event.categoryPressed(categoty: category))
    }

    func onDevSettingsPressed() {
        showDevSettings = true
        logManager.trackEvent(event: Event.devSettingsButtonPressed)
    }
    
    func onPushNotificationButtonPressed() {
        showPushNotificationModal = true
        logManager.trackEvent(event: Event.pushNotificationStart)
    }
    
    func onEnablePushNotificationModalPressed() {
        showPushNotificationModal = false
        
        Task {
            let isAuthorized = try await LocalNotifications.requestAuthorization()
            logManager.trackEvent(event: Event.pushNotificationEnable(isAuthorized: isAuthorized))
            await handleShowPushNotificationButton()
        }
    }
    
    func onCancelPushNotificationModalPressed() {
        showPushNotificationModal = false
        logManager.trackEvent(event: Event.pushNotificationCancel)
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

struct ExploreView: View {
    
    @State var viewModel: ExploreViewModel
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            List {
                if viewModel.featuredAvatars.isEmpty && viewModel.popularAvatars.isEmpty {
                    ZStack {
                        if viewModel.isLoadingPopular || viewModel.isLoadingFeatured {
                            loadingIndicator
                        } else {
                            errorMessageView
                        }
                    }
                    .removeListRowFormatting()
                }
                
                if viewModel.abTestManager.activeTests.categoryRowTest == .top {
                    categorySection
                }
                
                if !viewModel.featuredAvatars.isEmpty {
                    featuredSection
                }
                
                if !viewModel.popularAvatars.isEmpty {
                    if viewModel.abTestManager.activeTests.categoryRowTest == .original {
                        categorySection
                    }
                    popularSection
                }
            }
            .navigationTitle("Explore")
            .screenAppearAnalytics(name: "ExploreView")
            .navigationDestinationForCoreModule(path: $viewModel.path)
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.showDevSettingsButton {
                        devSettingsButton
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.showPushNotificationButton {
                        pushNotificationButton
                    }
                }
            })
            .sheet(isPresented: $viewModel.showDevSettings, content: {
                DevSettingsView()
            })
            .sheet(isPresented: $viewModel.showAppleProvider, content: {
                CreateAccountWithAppleView()
                    .presentationDetents([.medium])
            })
            .showModal($viewModel.showPushNotificationModal, content: {
                pushNotificationModal
            })
            .task {
                await viewModel.loadFeatureAvatars()
            }
            .task {
                await viewModel.loadPopularAvatars()
            }
            .task {
                await viewModel.handleShowPushNotificationButton()
            }
            .onFirstAppear {
                viewModel.schedulePushNotifications()
                viewModel.showCreateAccountIfNeeded()
            }
            .onOpenURL { url in
                viewModel.handleDeepLink(url: url)
            }
        }
    }
    
    // MARK: - Views
    private var devSettingsButton: some View {
        Text("DEV 👨‍💻")
            .anyButton(.press) {
                viewModel.onDevSettingsPressed()
            }
            .frame(width: 80)
    }
    
    private var loadingIndicator: some View {
        ProgressView()
            .padding(40)
            .frame(maxWidth: .infinity)
    }
    
    private var errorMessageView: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("Error")
                .font(.headline)
            Text("Please check your internet connection and try again.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Button("Try again") {
                viewModel.onTryAgainPressed()
            }
            .foregroundStyle(.blue)
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
        .padding(40)
    }
    
    private var featuredSection: some View {
        Section {
            ZStack {
                CarouselView(items: viewModel.featuredAvatars) { avatar in
                    HeroCellView(
                        title: avatar.name,
                        subtitle: avatar.characterDescription,
                        imageName: avatar.profileImageName,
                        lineWidth: 1.0
                    )
                    .anyButton {
                        viewModel.onAvatarPressed(avatar: avatar)
                    }
                }
            }
            .removeListRowFormatting()
        } header: {
            Text("Featured Avatars")
        }
    }

    private var categorySection: some View {
        Section {
            ZStack {
                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.categories, id: \.self) { category in
                            if let imageName = viewModel.popularAvatars.last(where: { $0.characterOption == category })?.profileImageName {
                                CategoryCellView(
                                    title: category.rawValue.capitalized,
                                    imageName: imageName,
                                    lineWidth: 1.0
                                )
                                .anyButton {
                                    viewModel.onCategoryPressed(category: category, imageName: imageName)
                                }
                            }
                        }
                    }
                    .scrollTargetLayout()
                }
                .frame(height: 150)
                .scrollClipDisabled(false)
                .scrollIndicators(.hidden)
                .scrollTargetBehavior(.viewAligned)
            }
            .removeListRowFormatting()
        } header: {
            Text("Categories")
        }
    }
    
    private var popularSection: some View {
        Section {
            ForEach(viewModel.popularAvatars, id: \.self) { avatar in
                CustomListCellView(
                    imageName: avatar.profileImageName,
                    title: avatar.name,
                    subtitle: avatar.characterDescription
                )
                .anyButton(.highlight) {
                    viewModel.onAvatarPressed(avatar: avatar)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Popular")
        }
    }
    
    private var pushNotificationButton: some View {
        Image(systemName: "bell.fill")
            .font(.headline)
            .padding(4)
            .tappableBackground()
            .foregroundStyle(.accent)
            .anyButton {
                viewModel.onPushNotificationButtonPressed()
            }
    }
    
    private var pushNotificationModal: some View {
        CustomModalView(
            title: "Enable push notifications?",
            subtitle: "We'll send you reminders and updates",
            primaryButtonTitle: "Enable",
            primaryButtonAction: {
                viewModel.onEnablePushNotificationModalPressed()
            },
            secondaryButtonTitle: "Cancel",
            secondaryButtonAction: {
                viewModel.onCancelPushNotificationModalPressed()
            }
        )
    }
}

// MARK: - Previews
#Preview("Has data") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(remote: MockAvatarService()))
    
    return ExploreView(viewModel: ExploreViewModel(container: container))
        .previewEnvironment()
}

#Preview("No data") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(remote: MockAvatarService(avatars: [], delay: 2.0)))
    
    return ExploreView(viewModel: ExploreViewModel(container: container))
        .previewEnvironment()
}

#Preview("Slow loading") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(remote: MockAvatarService(delay: 10)))
    
    return ExploreView(viewModel: ExploreViewModel(container: container))
        .previewEnvironment()
}

#Preview("CreateAccountTest, Has data") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(remote: MockAvatarService()))
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: .mock(isAnonymous: true))))
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(createAccountTest: true)))
    
    return ExploreView(viewModel: ExploreViewModel(container: container))
        .previewEnvironment()
}

#Preview("CategoryRowTest: Original") {
    let container = DevPreview.shared.container
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(categoryRowTest: .original)))
    
    return ExploreView(viewModel: ExploreViewModel(container: container))
        .previewEnvironment()
}

#Preview("CategoryRowTest: Top") {
    let container = DevPreview.shared.container
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(categoryRowTest: .top)))
    
    return ExploreView(viewModel: ExploreViewModel(container: container))
        .previewEnvironment()
}

#Preview("CategoryRowTest: Hidden") {
    let container = DevPreview.shared.container
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(categoryRowTest: .hidden)))
    
    return ExploreView(viewModel: ExploreViewModel(container: container))
        .previewEnvironment()
}
