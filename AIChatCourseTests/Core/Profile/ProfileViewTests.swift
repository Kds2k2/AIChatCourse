//
//  ProfileViewTests.swift
//  AIChatCourseTests
//
//  Created by Dmitro Kryzhanovsky on 04.03.2026.
//

import Testing
import SwiftUI
@testable import AIChatCourse

@MainActor
struct ProfileViewTests {

    @MainActor
    struct MockProfileInteractor: ProfileInteractor {
        let logger = MockLogService()
        let user = UserModel.mock
        
        var currentUser: UserModel? {
            user
        }
        
        func getAuthId() throws -> String {
            user.userId
        }
        
        func getAvatarsForUser(userId: String) async throws -> [AvatarModel] {
            AvatarModel.mocks
        }
        
        func removeAuthorIdFromAvatar(avatarId: String) async throws {
            
        }
        
        func trackEvent(event: any LoggableEvent) {
            logger.trackEvent(event: event)
        }
    }
    
    @MainActor
    struct AnyProfileInteractor: ProfileInteractor {
        let anyGetCurrentUser: UserModel?
        let anyGetAvatarsForUser: (String) async throws -> [AvatarModel]
        let anyRemoveAuthorIdFromAvatar: (String) async throws -> Void
        let anyTrackEvent: (any LoggableEvent) -> Void
        let anyGetAuthId: () throws -> String
        
        init(
            getCurrentUser: UserModel?,
            getAvatarsForUser: @escaping (String) async throws -> [AvatarModel],
            removeAuthorIdFromAvatar: @escaping (String) async throws -> Void,
            trackEvent: @escaping (any LoggableEvent) -> Void,
            getAuthId: @escaping () throws -> String
        ) {
            self.anyGetCurrentUser = getCurrentUser
            self.anyGetAvatarsForUser = getAvatarsForUser
            self.anyRemoveAuthorIdFromAvatar = removeAuthorIdFromAvatar
            self.anyTrackEvent = trackEvent
            self.anyGetAuthId = getAuthId
        }
        
        init(interactor: MockProfileInteractor) {
            self.anyGetCurrentUser = interactor.currentUser
            self.anyGetAvatarsForUser = interactor.getAvatarsForUser
            self.anyRemoveAuthorIdFromAvatar = interactor.removeAuthorIdFromAvatar
            self.anyTrackEvent = interactor.trackEvent
            self.anyGetAuthId = interactor.getAuthId
        }
        
        init(interactor: ProfileInteractor) {
            self.anyGetCurrentUser = interactor.currentUser
            self.anyGetAvatarsForUser = interactor.getAvatarsForUser
            self.anyRemoveAuthorIdFromAvatar = interactor.removeAuthorIdFromAvatar
            self.anyTrackEvent = interactor.trackEvent
            self.anyGetAuthId = interactor.getAuthId
        }
        
        var currentUser: UserModel? { anyGetCurrentUser }
        
        func getAvatarsForUser(userId: String) async throws -> [AvatarModel] {
            try await anyGetAvatarsForUser(userId)
        }
        
        func removeAuthorIdFromAvatar(avatarId: String) async throws {
            try await anyRemoveAuthorIdFromAvatar(avatarId)
        }
        
        func trackEvent(event: any LoggableEvent) {
            anyTrackEvent(event)
        }
        
        func getAuthId() throws -> String {
            try anyGetAuthId()
        }
    }
    
    @Test("loadData does set current User")
    func testLoadDataCurrentUser() async {
        // Given
        //let interactor = MockProfileInteractor()
        var events: [any LoggableEvent] = []
        let user = UserModel.mock
        let interactor = AnyProfileInteractor(
            getCurrentUser: UserModel.mock,
            getAvatarsForUser: { _ in
                AvatarModel.mocks
            },
            removeAuthorIdFromAvatar: { _ in },
            trackEvent: { event in
                events.append(event)
            },
            getAuthId: { UserModel.mock.userId }
        )
        
        let viewModel = ProfileViewModel(interactor: interactor)
        
        // When
        await viewModel.loadData()
        
        // Then
        #expect(interactor.currentUser?.userId == user.userId)
        #expect(events.contains { $0.eventName == ProfileViewModel.Event.loadAvatarsStart.eventName })
    }
    
// OLD VARIANT.
//    @Test("loadData does set current User")
//    func testLoadDataCurrentUser() async {
//        let container = DependencyContainer()
//
//        let mockLogService = MockLogService()
//        let logManager = LogManager(services: [mockLogService])
//        container.register(LogManager.self, service: logManager)
//
//        let mockUser = UserModel.mock
//        let userManager = UserManager(services: MockUserServices(user: mockUser))
//        container.register(UserManager.self, service: userManager)
//        
//        // Given
//        let viewModel = ProfileViewModel(interactor: .init(container: container))
//        
//        // When
//        await viewModel.loadData()
//        
//        // Then
//        #expect(viewModel.currentUser?.userId == mockUser.userId)
//        #expect(mockLogService.trackedEvents.contains { $0.name == ProfileViewModel.Event.loadAvatarsStart.eventName })
//    }
}
