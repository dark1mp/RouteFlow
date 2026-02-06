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
    @State private var showLaunchScreen = true

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
            ZStack {
                MainMapView(
                    locationService: locationService,
                    modelContext: sharedModelContainer.mainContext
                )
                .environmentObject(locationService)
                .modelContainer(sharedModelContainer)
                .onAppear {
                    locationService.requestPermission()
                }
                
                if showLaunchScreen {
                    LaunchScreenView()
                        .transition(.opacity)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showLaunchScreen = false
                                }
                            }
                        }
                }
            }
        }
    }
}
