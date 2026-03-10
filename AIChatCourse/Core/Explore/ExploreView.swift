//
//  ExploreView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 31.12.2025.
//

import SwiftUI

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
                
                if viewModel.categoryRowTest == .top {
                    categorySection
                }
                
                if !viewModel.featuredAvatars.isEmpty {
                    featuredSection
                }
                
                if !viewModel.popularAvatars.isEmpty {
                    if viewModel.categoryRowTest == .original {
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
    
    return ExploreView(viewModel: ExploreViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
}

#Preview("No data") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(remote: MockAvatarService(avatars: [], delay: 2.0)))
    
    return ExploreView(viewModel: ExploreViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
}

#Preview("Slow loading") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(remote: MockAvatarService(delay: 10)))
    
    return ExploreView(viewModel: ExploreViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
}

#Preview("CreateAccountTest, Has data") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(remote: MockAvatarService()))
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: .mock(isAnonymous: true))))
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(createAccountTest: true)))
    
    return ExploreView(viewModel: ExploreViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
}

#Preview("CategoryRowTest: Original") {
    let container = DevPreview.shared.container
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(categoryRowTest: .original)))
    
    return ExploreView(viewModel: ExploreViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
}

#Preview("CategoryRowTest: Top") {
    let container = DevPreview.shared.container
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(categoryRowTest: .top)))
    
    return ExploreView(viewModel: ExploreViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
}

#Preview("CategoryRowTest: Hidden") {
    let container = DevPreview.shared.container
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(categoryRowTest: .hidden)))
    
    return ExploreView(viewModel: ExploreViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
}
