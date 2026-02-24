//
//  UserModelTests.swift
//  AIChatCourseTests
//
//  Created by Dmitro Kryzhanovsky on 24.02.2026.
//

import Testing
import SwiftUI
@testable import AIChatCourse

@MainActor
struct UserModelTests {
    
    // MARK: - Helpers
    
    private func randomString() -> String {
        UUID().uuidString
    }
    
    private func randomBool() -> Bool {
        Bool.random()
    }
    
    private func randomHexColor() -> String {
        let letters = "0123456789ABCDEF"
        return "#" + String((0..<6).map { _ in letters.randomElement()! })
    }
    
    private func randomDate() -> Date {
        let seconds = Int.random(in: 0...4_000_000_000)
        return Date(timeIntervalSince1970: TimeInterval(seconds))
    }
    
    // MARK: - Tests
    
    @Test("Id should return userId")
    func idReturnsUserId() {
        let userId = randomString()
        let model = UserModel(userId: userId)
        
        #expect(model.id == userId)
    }
    
    @Test("UserModel Profile Color with Nil Hex")
    func profileColorWithNilHex() {
        let userId = randomString()
        let model = UserModel(userId: userId)
        
        #expect(model.profileColorCalculated == .accent)
    }
    
    @Test("Initializer should correctly assign all properties")
    func initializerAssignsProperties() {
        let userId = randomString()
        let email = randomString()
        let isAnonymous = randomBool()
        let createdAt = randomDate()
        let lastSignInAt = randomDate()
        let creationVersion = randomString()
        let didCompleteOnboarding = randomBool()
        let profileColorHex = randomHexColor()
        
        let model = UserModel(
            userId: userId,
            email: email,
            isAnonymous: isAnonymous,
            createdAt: createdAt,
            lastSignInAt: lastSignInAt,
            creationVersion: creationVersion,
            didCompleteOnboarding: didCompleteOnboarding,
            profileColorHex: profileColorHex
        )
        
        #expect(model.userId == userId)
        #expect(model.email == email)
        #expect(model.isAnonymous == isAnonymous)
        #expect(model.createdAt == createdAt)
        #expect(model.lastSignInAt == lastSignInAt)
        #expect(model.creationVersion == creationVersion)
        #expect(model.didCompleteOnboarding == didCompleteOnboarding)
        #expect(model.profileColorHex == profileColorHex)
    }
    
    @Test("Codable should correctly encode and decode with custom keys")
    func codableEncodesAndDecodesProperly() throws {
        let model = UserModel(
            userId: randomString(),
            email: randomString(),
            isAnonymous: randomBool(),
            createdAt: randomDate(),
            lastSignInAt: randomDate(),
            creationVersion: randomString(),
            didCompleteOnboarding: randomBool(),
            profileColorHex: randomHexColor()
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let data = try encoder.encode(model)
        let decoded = try decoder.decode(UserModel.self, from: data)
        
        #expect(decoded == model)
    }
    
    @Test("eventParameters should contain only non-nil prefixed values")
    func eventParametersContainOnlyNonNilValues() {
        let userId = randomString()
        let email = randomString()
        let isAnonymous = randomBool()
        
        let model = UserModel(
            userId: userId,
            email: email,
            isAnonymous: isAnonymous,
            createdAt: nil,
            lastSignInAt: nil,
            creationVersion: nil,
            didCompleteOnboarding: nil,
            profileColorHex: nil
        )
        
        let params = model.eventParameters
        
        #expect(params["user_user_id"] as? String == userId)
        #expect(params["user_email"] as? String == email)
        #expect(params["user_is_anonymous"] as? Bool == isAnonymous)
        
        #expect(params["user_created_at"] == nil)
        #expect(params["user_last_sign_in_at"] == nil)
        #expect(params["user_creating_version"] == nil)
        #expect(params["user_did_complete_onboarding"] == nil)
        #expect(params["user_profile_color_hex"] == nil)
    }
    
    @Test("profileColorCalculated should return accent color when hex is nil")
    func profileColorFallsBackToAccent() {
        let model = UserModel(userId: randomString())
        
        #expect(model.profileColorCalculated == .accent)
    }
    
    @Test("profileColorCalculated should return color created from hex")
    func profileColorUsesHexValue() {
        let hex = randomHexColor()
        let model = UserModel(
            userId: randomString(),
            profileColorHex: hex
        )
        
        #expect(model.profileColorCalculated == Color(hex: hex))
    }
    
    @Test("mock should return first element from mocks array")
    func mockReturnsFirstMock() {
        let first = UserModel.mocks.first
        let mock = UserModel.mock
        
        #expect(mock.userId == first?.userId)
    }
    
    @Test("mocks should contain predefined test users")
    func mocksContainUsers() {
        let mocks = UserModel.mocks
        
        #expect(!mocks.isEmpty)
        #expect(mocks.count >= 3)
    }
}
