//
//  RouteFlowApp.swift
//  RouteFlow
//
//  Created on 2026-02-06.
//

import SwiftUI
import SwiftData

@main
struct RouteFlowApp: App {
    @StateObject private var locationService = LocationService()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Route.self,
            Stop.self
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
                .environmentObject(locationService)
                .modelContainer(sharedModelContainer)
                .onAppear {
                    locationService.requestPermission()
                }
        }
    }
}
