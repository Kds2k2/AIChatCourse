//
//  ExploreView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 31.12.2025.
//

import SwiftUI

struct ExploreView: View {
    
    @Environment(AvatarManager.self) private var avatarManager
    
    @State private var categories: [CharacterOption] = CharacterOption.allCases
    
    @State private var featuredAvatars: [AvatarModel] = []
    @State private var popularAvatars: [AvatarModel] = []
    @State private var isLoadingFeatured: Bool = true
    @State private var isLoadingPopular: Bool = true
    
    @State private var path: [NavigationPathOption] = []
    
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
            .navigationDestinationForCoreModule(path: $path)
            .task {
                await loadFeatureAvatars()
            }
            .task {
                await loadPopularAvatars()
            }
        }
    }
    
    // MARK: - some Views
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
    
    // MARK: - private functions
    private func loadFeatureAvatars() async {
        guard featuredAvatars.isEmpty else { return }
        isLoadingFeatured = true
        
        do {
            featuredAvatars = try await avatarManager.getFeaturedAvatars()
        } catch {
            print("Error loading featured avatars: \(error)")
        }
        
        isLoadingFeatured = false
    }

    private func loadPopularAvatars() async {
        guard popularAvatars.isEmpty else { return }
        isLoadingPopular = true
        
        do {
            popularAvatars = try await avatarManager.getPopularAvatars()
        } catch {
            print("Error loading popular avatars: \(error)")
        }
        
        isLoadingPopular = false
    }
    
    private func onTryAgainPressed() {
        Task {
            await loadFeatureAvatars()
        }
        Task {
            await loadPopularAvatars()
        }
    }
    
    private func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId))
    }
    
    private func onCategoryPressed(category: CharacterOption, imageName: String) {
        path.append(.category(category: category, imageName: imageName))
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
