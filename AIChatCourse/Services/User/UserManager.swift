//
//  UserManager.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 11.01.2026.
//

import SwiftUI

@MainActor
@Observable
class UserManager {
    
    private let remote: RemoteUserService
    private let local: LocalUserPersistance
    private let logManager: LogManager?
    
    private(set) var currentUser: UserModel?
    private var streamUserTask: Task<Void, Never>?
    
    init(services: UserServices, logManager: LogManager? = nil) {
        self.remote = services.remote
        self.local = services.local
        self.logManager = logManager
        self.currentUser = local.getCurrentUser()
    }
    
    // MARK: - Remote
    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws {
        let creationVersion = isNewUser ? AppInfo.appVersion : nil
        let user = UserModel(auth: auth, creationVersion: creationVersion)
        logManager?.trackEvent(event: Event.logInStart(user: user))
        
        try await remote.saveUser(user: user)
        logManager?.trackEvent(event: Event.logInSuccess(user: user))
        startUserStream(userId: auth.uid)
    }
     
    func signOut() {
        stopUserStream()
        currentUser = nil
        logManager?.trackEvent(event: Event.signOut)
    }
    
    func deleleCurrentUser() async throws {
        logManager?.trackEvent(event: Event.deleteAccountStart)
        let uid = try currentUserId()
        try await remote.deleteUser(userId: uid)
        logManager?.trackEvent(event: Event.deleteAccountSuccess)
        signOut()
    }
    
    func markOnboardingCompletedForCurrentUser(profileColorHex: String) async throws {
        let uid = try currentUserId()
        try await remote.markOnboardingCompleted(userId: uid, profileColorHex: profileColorHex)
    }
    
    private func currentUserId() throws -> String {
        guard let uid = currentUser?.userId else {
            throw UserManagerError.noUserId
        }
        return uid
    }
    
    private func startUserStream(userId: String) {
        logManager?.trackEvent(event: Event.userStreamStart)
        streamUserTask?.cancel()
        
        streamUserTask = Task {
            do {
                for try await userUpdate in remote.streamUser(userId: userId) {
                    self.currentUser = userUpdate
                    logManager?.trackEvent(event: Event.userStreamSuccess(user: userUpdate))
                    logManager?.addUserProperties(dict: userUpdate.eventParameters, isHighPriority: true)
                    self.saveCurrentUserLocal()
                }
            } catch {
                self.currentUser = nil
                logManager?.trackEvent(event: Event.userStreamFail(error: error))
            }
        }
    }
    
    private func stopUserStream() {
        streamUserTask?.cancel()
        streamUserTask = nil
        logManager?.trackEvent(event: Event.userStreamStop)
    }
    
    // MARK: - Local
    private func saveCurrentUserLocal() {
        logManager?.trackEvent(event: Event.saveLocalStart(user: currentUser))
        Task {
            do {
                try local.saveCurrentUser(user: currentUser)
                logManager?.trackEvent(event: Event.saveLocalSuccess(user: currentUser))
            } catch {
                logManager?.trackEvent(event: Event.saveLocalFail(error: error))
            }
        }
    }
    
    // MARK: - Error
    enum UserManagerError: LocalizedError {
        case noUserId
    }
    
    // MARK: - Logs
    enum Event: LoggableEvent {
        case logInStart(user: UserModel), logInSuccess(user: UserModel)
        case userStreamStart, userStreamSuccess(user: UserModel), userStreamStop, userStreamFail(error: Error)
        case saveLocalStart(user: UserModel?), saveLocalSuccess(user: UserModel?), saveLocalFail(error: Error)
        case signOut
        case deleteAccountStart, deleteAccountSuccess
        
        var eventName: String {
            switch self {
            case .logInStart:                           return "UserManager_LogIn_Start"
            case .logInSuccess:                         return "UserManager_LogIn_Success"
            case .userStreamStart:                      return "UserManager_UserStream_Start"
            case .userStreamSuccess:                    return "UserManager_UserStream_Success"
            case .userStreamStop:                       return "UserManager_UserStream_Stop"
            case .userStreamFail:                       return "UserManager_UserStream_Fail"
            case .saveLocalStart:                       return "UserManager_SaveLocal_Start"
            case .saveLocalSuccess:                     return "UserManager_SaveLocal_Success"
            case .saveLocalFail:                        return "UserManager_SaveLocal_Fail"
            case .signOut:                              return "UserManager_SignOut"
            case .deleteAccountStart:                   return "UserManager_DeleteAccount_Start"
            case .deleteAccountSuccess:                 return "UserManager_DeleteAccount_Success"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .saveLocalFail(error: let error), .userStreamFail(error: let error):
                return error.eventParameters
            case .logInStart(user: let user), .logInSuccess(user: let user), .userStreamSuccess(user: let user):
                return user.eventParameters
            case .saveLocalStart(user: let user), .saveLocalSuccess(user: let user):
                return user?.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .saveLocalFail, .userStreamFail:
                    .severe
            default:
                    .analytic
            }
        }
    }
}
