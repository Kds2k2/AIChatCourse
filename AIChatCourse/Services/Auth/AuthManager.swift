//
//  AuthManager.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 10.01.2026.
//
import SwiftUI
import CryptoKit
import AuthenticationServices

@MainActor
@Observable
class AuthManager {
    
    private let service: AuthService
    private(set) var auth: UserAuthInfo?
    private var logManager: LogManager?
    private var nonse: String?
    private var listener: (any NSObjectProtocol)?
    
    init(service: AuthService, logManager: LogManager? = nil) {
        self.service = service
        self.auth = service.getAuthenticatedUser()
        self.logManager = logManager
        self.addAuthListener()
    }
    
    private func addAuthListener() {
        logManager?.trackEvent(event: Event.authListenerStart)
        if let listener {
            service.removeAuthenticatedListener(listener: listener)
        }
        
        Task {
            for await value in service.addAuthenticatedListener(onListenerAttached: { listener in
                self.listener = listener
            }) {
                self.auth = value
                logManager?.trackEvent(event: Event.authListenerSuccess(user: value))
                
                if let value {
                    logManager?.identifyUser(userId: value.uid, name: nil, email: value.email)
                    logManager?.addUserProperties(dict: value.eventParameters, isHighPriority: true)
                    logManager?.addUserProperties(dict: AppInfo.eventParameters, isHighPriority: false)
                }
            }
        }
    }
    
    func getAuthId() throws -> String {
        guard let uid = auth?.uid else {
            throw AuthError.notSignedIn
        }
        
        return uid
    }
    
    func singInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await service.singInAnonymously()
    }
    
    func signInWithApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        defer { self.addAuthListener() }
        return try await service.signInWithApple()
    }
    
    func signInWithEmailAndPassword(email: String, password: String) async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        defer { self.addAuthListener() }
        return try await service.signInWithEmailAndPassword(email: email, password: password)
    }
    
    func signUpWithEmailAndPassword(email: String, password: String) async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        defer { self.addAuthListener() }
        return try await service.signUpWithEmailAndPassword(email: email, password: password)
    }
    
    func signOut() throws {
        logManager?.trackEvent(event: Event.signOutStart)
        try service.signOut()
        auth = nil
        logManager?.trackEvent(event: Event.signOutSuccess)
    }
    
    func deleteAccount() async throws {
        logManager?.trackEvent(event: Event.deleteAccountStart)
        try await service.deleteAccount()
        auth = nil
        logManager?.trackEvent(event: Event.deleteAccountSuccess)
    }
    
    // MARK: - Error
    enum AuthError: LocalizedError {
        case notSignedIn
    }
    
    // MARK: - Logs
    enum Event: LoggableEvent {
        case authListenerStart, authListenerSuccess(user: UserAuthInfo?)
        case signOutStart, signOutSuccess
        case deleteAccountStart, deleteAccountSuccess
        
        var eventName: String {
            switch self {
            case .authListenerStart:            return "AuthManager_AuthListener_Start"
            case .authListenerSuccess:          return "AuthManager_AuthListener_Success"
            case .signOutStart:                 return "AuthManager_SignOut_Start"
            case .signOutSuccess:               return "AuthManager_SignOut_Success"
            case .deleteAccountStart:           return "AuthManager_DeleteAccount_Start"
            case .deleteAccountSuccess:         return "AuthManager_DeleteAccount_Success"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .authListenerSuccess(user: let user):
                return user?.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            default:
                    .analytic
            }
        }
    }
}
