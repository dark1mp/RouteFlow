//
//  OptimizeRouteView.swift
//  RouteFlow
//
//  Created on 2026-02-06.
//

import SwiftUI
import MapKit

struct OptimizeRouteView: View {
    let route: Route
    let locationService: LocationService
    @Environment(\.dismiss) private var dismiss
    @State private var isOptimizing = false
    @State private var isOptimized = false
    @State private var originalDistance: Double = 0
    @State private var optimizedDistance: Double = 0
    @State private var showOriginal = false
    @State private var mapPosition: MapCameraPosition = .automatic

    private let optimizationService = RouteOptimizationService()

    private var timeSaved: String {
        let diff = originalDistance - optimizedDistance
        guard diff > 0 else { return "0m" }
        let timeSec = diff / 13.4 // average speed
        let minutes = Int(timeSec) / 60
        if minutes > 60 {
            return "\(minutes / 60)h \(minutes % 60)m"
        }
        return "\(minutes)m"
    }

    private var distanceSaved: String {
        let diff = originalDistance - optimizedDistance
        guard diff > 0 else { return "0 km" }
        return String(format: "%.1f km", diff / 1000)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Map with route polyline
                routeMap
                    .frame(height: 280)

                // Toggle original / optimized
                if isOptimized {
                    Picker("View", selection: $showOriginal) {
                        Text("Optimized").tag(false)
                        Text("Original").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                }

                // Stats
                if isOptimized {
                    statsComparison
                        .padding(.horizontal)

                    Spacer()

                    // Stop order
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Optimized order")
                            .font(.headline)
                            .padding(.horizontal)

                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(route.stops.sorted(by: { $0.sequenceNumber < $1.sequenceNumber })) { stop in
                                    HStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.green.opacity(0.2))
                                                .frame(width: 32, height: 32)
                                            Text("\(stop.sequenceNumber)")
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundColor(.green)
                                        }

                                        Text(stop.address)
                                            .font(.subheadline)
                                            .lineLimit(1)

                                        Spacer()

                                        if let eta = stop.estimatedArrivalTime {
                                            Text(eta, style: .time)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)

                                    if stop.sequenceNumber < route.stops.count {
                                        Divider().padding(.leading, 56)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    Spacer()

                    // Pre-optimization info
                    VStack(spacing: 16) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 48))
                            .foregroundColor(.blue)

                        Text("Optimize your route")
                            .font(.title3)
                            .fontWeight(.semibold)

                        Text("\(route.stops.count) stops will be reordered to minimize travel time and distance")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }

                    Spacer()
                }

                // Action button
                Button {
                    if isOptimized {
                        dismiss()
                    } else {
                        optimizeRoute()
                    }
                } label: {
                    HStack {
                        if isOptimizing {
                            ProgressView()
                                .tint(.white)
                        }
                        Text(isOptimized ? "Done" : "Optimize Route")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(isOptimized ? Color.green : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(isOptimizing)
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

    // MARK: - Map

    private var routeMap: some View {
        Map(position: $mapPosition) {
            ForEach(route.stops.sorted(by: { $0.sequenceNumber < $1.sequenceNumber })) { stop in
                Annotation("", coordinate: stop.coordinate) {
                    StopAnnotationView(stop: stop)
                }
            }

            // Polyline between stops
            let sortedStops = route.stops.sorted(by: { $0.sequenceNumber < $1.sequenceNumber })
            if sortedStops.count >= 2 {
                MapPolyline(coordinates: sortedStops.map { $0.coordinate })
                    .stroke(isOptimized ? Color.green : Color.blue, lineWidth: 3)
            }
        }
        .mapControls { }
        .onAppear {
            fitMapToStops()
        }
    }

    private func fitMapToStops() {
        let coordinates = route.stops.map { $0.coordinate }
        guard !coordinates.isEmpty else { return }

        let minLat = coordinates.map { $0.latitude }.min() ?? 0
        let maxLat = coordinates.map { $0.latitude }.max() ?? 0
        let minLon = coordinates.map { $0.longitude }.min() ?? 0
        let maxLon = coordinates.map { $0.longitude }.max() ?? 0

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: max((maxLat - minLat) * 1.5, 0.01),
            longitudeDelta: max((maxLon - minLon) * 1.5, 0.01)
        )
        mapPosition = .region(MKCoordinateRegion(center: center, span: span))
    }

    // MARK: - Stats

    private var statsComparison: some View {
        HStack(spacing: 16) {
            statCard(
                title: "Distance saved",
                value: distanceSaved,
                icon: "arrow.down.right",
                color: .green
            )

            statCard(
                title: "Time saved",
                value: timeSaved,
                icon: "clock.arrow.circlepath",
                color: .green
            )

            statCard(
                title: "Total",
                value: String(format: "%.1f km", optimizedDistance / 1000),
                icon: "road.lanes",
                color: .blue
            )
        }
    }

    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)

            Text(value)
                .font(.headline)

            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }

    // MARK: - Optimization

    private func optimizeRoute() {
        isOptimizing = true

        let startLocation = locationService.currentLocation ?? CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

        // Calculate original distance first
        originalDistance = optimizationService.calculateTotalDistance(stops: route.stops, from: startLocation)

        Task {
            let optimized = await optimizationService.optimizeRoute(stops: route.stops, startLocation: startLocation)

            // Update route with optimized data
            route.stops = optimized
            route.isOptimized = true
            optimizedDistance = optimizationService.calculateTotalDistance(stops: optimized, from: startLocation)
            route.totalDistance = optimizedDistance

            // Calculate total duration
            var totalDuration: TimeInterval = 0
            var prevLocation = startLocation
            for stop in optimized {
                let distance = prevLocation.distance(to: stop.coordinate)
                totalDuration += distance / 13.4 + 180
                prevLocation = stop.coordinate
            }
            route.estimatedDuration = totalDuration
            route.updatedAt = Date()

            isOptimizing = false
            isOptimized = true
            fitMapToStops()
        }
    }
}
