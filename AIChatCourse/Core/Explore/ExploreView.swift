//
//  ExploreView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 31.12.2025.
//

import SwiftUI

struct ExploreView: View {
    
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(LogManager.self) private var logManager
    
    @State private var categories: [CharacterOption] = CharacterOption.allCases
    
    @State private var featuredAvatars: [AvatarModel] = []
    @State private var popularAvatars: [AvatarModel] = []
    @State private var isLoadingFeatured: Bool = true
    @State private var isLoadingPopular: Bool = true
    
    @State private var path: [NavigationPathOption] = []
    
    @State private var showDevSettings: Bool = false
    private var showDevSettingsButton: Bool {
        #if DEV || MOCK
            return true
        #else
            return false
        #endif
    }

    var body: some View {
        NavigationStack(path: $path) {
            List {
                if featuredAvatars.isEmpty && popularAvatars.isEmpty {
                    ZStack {
                        if isLoadingPopular || isLoadingFeatured {
                            loadingIndicator
                        } else {
                            errorMessageView
                        }
                    }
                    .removeListRowFormatting()
                }
                
                if !featuredAvatars.isEmpty {
                    featuredSection
                }
                
                if !popularAvatars.isEmpty {
                    categorySection
                    popularSection
                }
            }
            .navigationTitle("Explore")
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    if showDevSettingsButton {
                        devSettingsButton
                    }
                }
            })
            .sheet(isPresented: $showDevSettings, content: {
                DevSettingsView()
            })
            .navigationDestinationForCoreModule(path: $path)
            .screenAppearAnalytics(name: "ExploreView")
            .task {
                await loadFeatureAvatars()
            }
            .task {
                await loadPopularAvatars()
            }
        }
    }

    // MARK: - Views
    private var devSettingsButton: some View {
        Text("DEV 👨‍💻")
            .anyButton(.press) {
                onDevSettingsPressed()
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
                onTryAgainPressed()
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
                CarouselView(items: featuredAvatars) { avatar in
                    HeroCellView(
                        title: avatar.name,
                        subtitle: avatar.characterDescription,
                        imageName: avatar.profileImageName,
                        lineWidth: 1.0
                    )
                    .anyButton {
                        onAvatarPressed(avatar: avatar)
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
                        ForEach(categories, id: \.self) { category in
                            if let imageName = popularAvatars.last(where: { $0.characterOption == category })?.profileImageName {
                                CategoryCellView(
                                    title: category.rawValue.capitalized,
                                    imageName: imageName,
                                    lineWidth: 1.0
                                )
                                .anyButton {
                                    onCategoryPressed(category: category, imageName: imageName)
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
            ForEach(popularAvatars, id: \.self) { avatar in
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
        } header: {
            Text("Popular")
        }
    }
    
    // MARK: - Actions
    private func loadFeatureAvatars() async {
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

    private func loadPopularAvatars() async {
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
    
    private func onTryAgainPressed() {
        logManager.trackEvent(event: Event.tryAgainButtonPressed)
        Task {
            await loadFeatureAvatars()
        }
        Task {
            await loadPopularAvatars()
        }
    }
    
    private func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
        logManager.trackEvent(event: Event.avatarPressed(avatar: avatar))
    }
    
    private func onCategoryPressed(category: CharacterOption, imageName: String) {
        path.append(.category(category: category, imageName: imageName))
        logManager.trackEvent(event: Event.categoryPressed(categoty: category))
    }

    private func onDevSettingsPressed() {
        showDevSettings = true
        logManager.trackEvent(event: Event.devSettingsButtonPressed)
    }
    
    // MARK: - Logs
    enum Event: LoggableEvent {
        case loadFeatureAvatarsStart, loadFeatureAvatarsSuccess, loadFeatureAvatarsFail(error: Error)
        case loadPopularAvatarsStart, loadPopularAvatarsSuccess, loadPopularAvatarsFail(error: Error)
        case avatarPressed(avatar: AvatarModel), categoryPressed(categoty: CharacterOption)
        case tryAgainButtonPressed, devSettingsButtonPressed
        
        static var screenName: String = "ExploreView"
        
        var eventName: String {
            switch self {
            case .loadFeatureAvatarsStart:                   return "\(Event.screenName)_LoadFeatureAvatars_"
            case .loadFeatureAvatarsSuccess:                 return "\(Event.screenName)_LoadFeatureAvatars_"
            case .loadFeatureAvatarsFail:                    return "\(Event.screenName)_LoadFeatureAvatars_"
            case .loadPopularAvatarsStart:                   return "\(Event.screenName)_LoadPopularAvatars_"
            case .loadPopularAvatarsSuccess:                 return "\(Event.screenName)_LoadPopularAvatars_"
            case .loadPopularAvatarsFail:                    return "\(Event.screenName)_LoadPopularAvatars_"
            case .avatarPressed:                             return "\(Event.screenName)_Avatar_Pressed"
            case .categoryPressed:                           return "\(Event.screenName)_Category_Pressed"
            case .tryAgainButtonPressed:                     return "\(Event.screenName)_TryAgainButton_Pressed"
            case .devSettingsButtonPressed:                  return "\(Event.screenName)_DevSettingsButton_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadFeatureAvatarsFail(error: let error), .loadPopularAvatarsFail(error: let error):
                return error.eventParameters
            case .avatarPressed(avatar: let avatar):
                return avatar.eventParameters
            case .categoryPressed(categoty: let category):
                return ["category": category.rawValue]
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

#Preview("Has data") {
    ExploreView()
        .environment(AvatarManager(remote: MockAvatarService()))
}

#Preview("No data") {
    ExploreView()
        .environment(AvatarManager(remote: MockAvatarService(avatars: [], delay: 2.0)))
}

#Preview("Slow loading") {
    ExploreView()
        .environment(AvatarManager(remote: MockAvatarService(delay: 10)))
}
