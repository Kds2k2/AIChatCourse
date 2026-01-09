//
//  UserAuthInfo+Firebase.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 08.01.2026.
//

import FirebaseAuth

extension UserAuthInfo {
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.isAnonymous = user.isAnonymous
        self.createdAt = user.metadata.creationDate
        self.lastSignInAt = user.metadata.lastSignInDate
    }
}
