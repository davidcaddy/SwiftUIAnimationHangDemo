//
//  DraggableTestApp.swift
//  DraggableTest
//
//  Created by David Caddy on 24/3/2024.
//

import SwiftUI
import SwiftData

@main
struct DraggableTestApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            SidebarItem.self,
            InnerSidebarItem.self,
            DetailItem.self,
            InnerDetailItem.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
