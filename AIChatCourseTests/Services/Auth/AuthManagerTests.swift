//
//  AuthManagerTests.swift
//  AIChatCourseTests
//
//  Created by Dmitro Kryzhanovsky on 24.02.2026.
//

import Testing
import SwiftUI
@testable import AIChatCourse

@MainActor
struct AuthManagerTests {
    
    // MARK: - Helpers
    
    private func randomString() -> String {
        UUID().uuidString
    }
    
    private func randomUser(isAnonymous: Bool = false) -> UserAuthInfo {
        UserAuthInfo(
            uid: randomString(),
            email: isAnonymous ? nil : "\(randomString())@test.com",
            isAnonymous: isAnonymous,
            createdAt: Date(timeIntervalSince1970: TimeInterval(Int.random(in: 0...4_000_000_000))),
            lastSignInAt: Date(timeIntervalSince1970: TimeInterval(Int.random(in: 0...4_000_000_000)))
        )
    }
    
    // MARK: - Tests
    
    @Test("Init should set current authenticated user from service")
    func initSetsInitialUser() async {
        let user = randomUser()
        let service = MockAuthService(user: user)
        let logger = MockLogService()
        
        let manager = AuthManager(service: service, logManager: LogManager(services: [logger]))
        
        #expect(manager.auth?.uid == user.uid)
    }
    
    @Test("Auth listener should log success and identify user")
    func authListenerLogsAndIdentifiesUser() async throws {
        let user = randomUser()
        let service = MockAuthService(user: user)
        let logger = MockLogService()
        
        _ = AuthManager(service: service, logManager: LogManager(services: [logger]))
        
        // Allow async listener to execute
        try await Task.sleep(nanoseconds: 50_000_000)
        
        #expect(logger.trackedEvents.contains {
            $0.name == "AuthManager_AuthListener_Success"
        })
        
        #expect(logger.identifyCalls.count == 1)
        #expect(logger.identifyCalls.first?.userId == user.uid)
        
        #expect(logger.userPropertiesCalls.count >= 1)
    }
    
    @Test("getAuthId should return uid when signed in")
    func getAuthIdReturnsUid() throws {
        let user = randomUser()
        let service = MockAuthService(user: user)
        
        let manager = AuthManager(service: service)
        
        let id = try manager.getAuthId()
        #expect(id == user.uid)
    }
    
    @Test("getAuthId should throw when not signed in")
    func getAuthIdThrowsWhenNoUser() {
        let service = MockAuthService(user: nil)
        let manager = AuthManager(service: service)
        
        #expect(throws: AuthManager.AuthError.notSignedIn) {
            try manager.getAuthId()
        }
    }
    
    @Test("signOut should clear auth and log events")
    func signOutClearsUserAndLogs() throws {
        let user = randomUser()
        let service = MockAuthService(user: user)
        let logger = MockLogService()
        
        let manager = AuthManager(service: service, logManager: LogManager(services: [logger]))
        
        try manager.signOut()
        
        #expect(manager.auth == nil)
        
        #expect(logger.trackedEvents.contains {
            $0.name == "AuthManager_SignOut_Start"
        })
        
        #expect(logger.trackedEvents.contains {
            $0.name == "AuthManager_SignOut_Success"
        })
    }
    
    @Test("deleteAccount should clear auth and log events")
    func deleteAccountClearsUserAndLogs() async throws {
        let user = randomUser()
        let service = MockAuthService(user: user)
        let logger = MockLogService()
        
        let manager = AuthManager(service: service, logManager: LogManager(services: [logger]))
        
        try await manager.deleteAccount()
        
        #expect(manager.auth == nil)
        
        #expect(logger.trackedEvents.contains {
            $0.name == "AuthManager_DeleteAccount_Start"
        })
        
        #expect(logger.trackedEvents.contains {
            $0.name == "AuthManager_DeleteAccount_Success"
        })
    }
    
    @Test("signInAnonymously should return anonymous user")
    func signInAnonymouslyReturnsAnonymousUser() async throws {
        let service = MockAuthService()
        let manager = AuthManager(service: service)
        
        let result = try await manager.singInAnonymously()
        
        #expect(result.user.isAnonymous == true)
        #expect(result.isNewUser == true)
    }
    
    @Test("signInWithApple should return non-anonymous user")
    func signInWithAppleReturnsUser() async throws {
        let service = MockAuthService()
        let manager = AuthManager(service: service)
        
        let result = try await manager.signInWithApple()
        
        #expect(result.user.isAnonymous == false)
        #expect(result.isNewUser == false)
    }
}
