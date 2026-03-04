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

    @Test("loadData does set current User")
    func testLoadDataCurrentUser() async {
        let container = DependencyContainer()

        let mockLogService = MockLogService()
        let logManager = LogManager(services: [mockLogService])
        container.register(LogManager.self, service: logManager)

        let mockUser = UserModel.mock
        let userManager = UserManager(services: MockUserServices(user: mockUser))
        container.register(UserManager.self, service: userManager)
        
        container.register(AvatarManager.self, service: AvatarManager(remote: MockAvatarService()))
        container.register(AuthManager.self, service: AuthManager(service: MockAuthService()))
        
        // Given
        let viewModel = ProfileViewModel(container: container)
        
        // When
        await viewModel.loadData()
        
        // Then
        #expect(viewModel.currentUser?.userId == mockUser.userId)
        #expect(mockLogService.trackedEvents.contains { $0.name == ProfileViewModel.Event.loadAvatarsStart.eventName })
    }
}
