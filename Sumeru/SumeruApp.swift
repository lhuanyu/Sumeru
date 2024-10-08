//
//  SumeruApp.swift
//  Sumeru
//
//  Created by LuoHuanyu on 2024/6/30.
//

import SwiftUI
import SwiftData

@main
struct SumeruApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Care.self,
            Feed.self,
            Diaper.self,
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
