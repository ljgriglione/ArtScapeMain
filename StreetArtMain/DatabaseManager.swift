//
//  DatabaseManager.swift
//  StreetArtMain
//
//  Created by Logan Griglione on 1/30/25.
//

import SwiftData

struct DatabaseManager {
    static func resetDatabase(context: ModelContext) async throws {
        let fetchDescriptor = FetchDescriptor<ArtData>()
        let allItems = try context.fetch(fetchDescriptor)

        for item in allItems {
            context.delete(item)
        }

        try context.save()
        print("Database reset successfully!")
    }
}
