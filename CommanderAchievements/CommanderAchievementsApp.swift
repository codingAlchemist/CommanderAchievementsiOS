//
//  CommanderAchievementsApp.swift
//  CommanderAchievements
//
//  Created by jason debottis on 7/28/26.
//

import SwiftUI
import SwiftData
import FirebaseCore
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct CommanderAchievementsApp: App {
    private static let schemaVersionKey = "CommanderAchievements.SchemaVersion"
    private static let currentSchemaVersion = 2

    private static var storeURL: URL {
        let baseURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return baseURL.appending(path: "CommanderAchievements.store")
    }

    private static func makeContainer(schema: Schema, resetStoreOnFailure: Bool) throws -> ModelContainer {
        let config = ModelConfiguration(schema: schema, url: storeURL, cloudKitDatabase: .none)

        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            guard resetStoreOnFailure else { throw error }

            // Last-resort recovery if the persistent store cannot be opened.
            let fileManager = FileManager.default
            let sidecarURLs = [
                storeURL,
                storeURL.appendingPathExtension("shm"),
                storeURL.appendingPathExtension("wal")
            ]
            for url in sidecarURLs where fileManager.fileExists(atPath: url.path) {
                try? fileManager.removeItem(at: url)
            }

            return try ModelContainer(for: schema, configurations: [config])
        }
    }

    private static func runMigrationsIfNeeded(using container: ModelContainer) {
        let defaults = UserDefaults.standard
        let storedSchemaVersion = defaults.integer(forKey: schemaVersionKey)
        guard storedSchemaVersion < currentSchemaVersion else { return }

        let context = ModelContext(container)

        do {
            if storedSchemaVersion < 2 {
                try migrateCompletedAchievementsToIncludeMetadata(context: context)
            }

            try context.save()
            defaults.set(currentSchemaVersion, forKey: schemaVersionKey)
        } catch {
            print("Schema migration failed: \(error)")
        }
    }

    private static func migrateCompletedAchievementsToIncludeMetadata(context: ModelContext) throws {
        let completedDescriptor = FetchDescriptor<CompletedAchievementEntity>()
        let achievementDescriptor = FetchDescriptor<AchievementEntity>()

        let completedAchievements = try context.fetch(completedDescriptor)
        let achievements = try context.fetch(achievementDescriptor)
        let achievementsByID = Dictionary(uniqueKeysWithValues: achievements.map { ($0.id, $0) })

        for completed in completedAchievements {
            guard let source = achievementsByID[completed.id] else { continue }

            // Backfill metadata only when a record still has legacy/empty values.
            if completed.title.isEmpty { completed.title = source.title }
            if completed.achievementDescription.isEmpty { completed.achievementDescription = source.achievementDescription }
            if completed.rarity.isEmpty { completed.rarity = source.rarity }
            if completed.category.isEmpty { completed.category = source.category }
            if completed.points == 0 { completed.points = source.points }
        }
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            AchievementEntity.self,
            CompletedAchievementEntity.self
        ])

        do {
            let container = try CommanderAchievementsApp.makeContainer(schema: schema, resetStoreOnFailure: true)
            CommanderAchievementsApp.runMigrationsIfNeeded(using: container)
            return container
        } catch {
            fatalError("Could not create any ModelContainer: \(error)")
        }
    }()

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
