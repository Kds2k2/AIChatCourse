//
//  SwiftDataLocalPersistence.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 15.01.2026.
//

import SwiftUI
import SwiftData

@MainActor
struct SwiftDataLocalPersistence: LocalAvatarPersistence {
    private let container: ModelContainer
    private var context: ModelContext {
        container.mainContext
    }
    
    init() {
        // swiftlint:disable:next force_try
        self.container = try! ModelContainer(for: AvatarEntity.self)
    }
    
    func addRecentAvatar(avatar: AvatarModel) throws {
        let entity = AvatarEntity(from: avatar)
        context.insert(entity)
        try context.save()
    }
    
    func getRecentAvatars() throws -> [AvatarModel] {
        let desc = FetchDescriptor<AvatarEntity>(sortBy: [SortDescriptor(\.addedAt, order: .reverse)])
        let entities = try context.fetch(desc)
        return entities.map({ $0.toModel() })
    }
}
