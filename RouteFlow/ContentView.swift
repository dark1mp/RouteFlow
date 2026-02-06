//
//  ContentView.swift
//  RouteFlow
//
//  Created on 2026-02-06.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var routes: [Route]
    @EnvironmentObject private var locationService: LocationService
    @State private var showingNewRoute = false

    var body: some View {
        NavigationStack {
            ZStack {
                if routes.isEmpty {
                    emptyStateView
                } else {
                    routeListView
                }
            }
            .navigationTitle("RouteFlow")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingNewRoute = true
                    } label: {
                        Label("New Route", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewRoute) {
                NewRouteView()
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "map")
                .font(.system(size: 80))
                .foregroundColor(.blue)

            Text("No Routes Yet")
                .font(.title)
                .fontWeight(.bold)

            Text("Create your first delivery route to get started")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showingNewRoute = true
            } label: {
                Label("Create Route", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }

    private var routeListView: some View {
        List {
            ForEach(routes) { route in
                NavigationLink {
                    RouteDetailView(route: route)
                } label: {
                    RouteRowView(route: route)
                }
            }
            .onDelete(perform: deleteRoutes)
        }
    }

    private func deleteRoutes(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(routes[index])
        }
    }
}

// MARK: - Route Row View
struct RouteRowView: View {
    let route: Route

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(route.name)
                .font(.headline)

            HStack {
                Label("\(route.totalStops) stops", systemImage: "mappin.and.ellipse")
                    .font(.caption)

                Spacer()

                if route.isOptimized {
                    Label("Optimized", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }

            ProgressView(value: route.progressPercentage)
                .tint(.blue)

            Text("\(route.completedStops)/\(route.totalStops) completed")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - New Route View
struct NewRouteView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var routeName = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Route Details") {
                    TextField("Route Name", text: $routeName)
                }
            }
            .navigationTitle("New Route")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createRoute()
                    }
                    .disabled(routeName.isEmpty)
                }
            }
        }
    }

    private func createRoute() {
        let newRoute = Route(name: routeName)
        modelContext.insert(newRoute)
        dismiss()
    }
}

// MARK: - Route Detail View
struct RouteDetailView: View {
    let route: Route
    @EnvironmentObject private var locationService: LocationService
    @State private var showAddStops = false
    @State private var showOptimize = false

    var body: some View {
        ZStack {
            if route.stops.isEmpty {
                emptyStopsView
            } else {
                VStack(spacing: 0) {
                    // Map showing all stops
                    MapWithPinsView(stops: route.stops, showRoute: route.isOptimized)
                        .frame(height: 300)

                    // Stats card
                    statsCard

                    // Stop list
                    List {
                        ForEach(route.stops) { stop in
                            StopListRow(stop: stop)
                        }
                    }
                }
            }
        }
        .navigationTitle(route.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showAddStops = true
                    } label: {
                        Label("Add Stops", systemImage: "plus.circle")
                    }

                    if route.stops.count >= 2 && !route.isOptimized {
                        Button {
                            showOptimize = true
                        } label: {
                            Label("Optimize Route", systemImage: "arrow.triangle.2.circlepath")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showAddStops) {
            AddStopsView(route: route, locationService: locationService)
        }
        .sheet(isPresented: $showOptimize) {
            OptimizeRouteView(route: route, locationService: locationService)
        }
    }

    private var emptyStopsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "mappin.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("No Stops Added")
                .font(.title2)
                .fontWeight(.bold)

            Text("Add delivery stops to build your route")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showAddStops = true
            } label: {
                Label("Add Stops", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }

    private var statsCard: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Total Stops")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(route.totalStops)")
                    .font(.title2)
                    .fontWeight(.bold)
            }

            Divider()

            if route.isOptimized {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Distance")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(route.formattedDistance)
                        .font(.title3)
                        .fontWeight(.semibold)
                }

                Divider()

                VStack(alignment: .leading, spacing: 4) {
                    Text("Duration")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(route.formattedDuration)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }

            Spacer()

            if route.isOptimized {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
}

struct StopListRow: View {
    let stop: Stop

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(stop.status.color.opacity(0.2))
                    .frame(width: 40, height: 40)

                Text("\(stop.sequenceNumber)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(stop.status.color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(stop.address)
                    .font(.body)

                if !stop.notes.isEmpty {
                    Text(stop.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                HStack(spacing: 8) {
                    Image(systemName: stop.status.icon)
                        .font(.caption)
                    Text(stop.status.rawValue)
                        .font(.caption)
                }
                .foregroundColor(stop.status.color)
            }

            Spacer()

            if let eta = stop.estimatedArrivalTime {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("ETA")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(eta, style: .time)
                        .font(.caption)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// Placeholder for optimize view
struct OptimizeRouteView: View {
    let route: Route
    let locationService: LocationService
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                Text("Route optimization coming soon!")
                    .font(.title3)
                    .padding()
            }
            .navigationTitle("Optimize Route")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Route History View (accessible from side menu)
struct RouteHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var routes: [Route]
    @EnvironmentObject private var locationService: LocationService
    @State private var showingNewRoute = false

    var body: some View {
        ZStack {
            if routes.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "map")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)

                    Text("No Routes Yet")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Routes will appear here once you add stops from the map")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            } else {
                List {
                    ForEach(routes) { route in
                        NavigationLink {
                            RouteDetailView(route: route)
                        } label: {
                            RouteRowView(route: route)
                        }
                    }
                    .onDelete { offsets in
                        for index in offsets {
                            modelContext.delete(routes[index])
                        }
                    }
                }
            }
        }
        .navigationTitle("My Routes")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ContentView()
        .environmentObject(LocationService())
        .modelContainer(for: [Route.self, Stop.self], inMemory: true)
}
