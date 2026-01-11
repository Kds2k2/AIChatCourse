//
//  AuthService.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 10.01.2026.
//

import SwiftUI

protocol AuthService: Sendable {
    func addAuthenticatedListener(onListenerAttached: (any NSObjectProtocol) -> Void) -> AsyncStream<UserAuthInfo?>
    func getAuthenticatedUser() -> UserAuthInfo?
    func singInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func signInWithEmailAndPassword(email: String, password: String) async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func signUpWithEmailAndPassword(email: String, password: String) async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func signOut() throws
    func deleteAccount() async throws
}
