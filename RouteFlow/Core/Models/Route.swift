//
//  Route.swift
//  RouteFlow
//
//  Created on 2026-02-06.
//

import Foundation
import SwiftData
import CoreLocation

@Model
final class Route {
    var id: UUID
    var name: String
    @Relationship(deleteRule: .cascade) var stops: [Stop]
    var isOptimized: Bool
    var totalDistance: Double // in meters
    var estimatedDuration: TimeInterval // in seconds
    var startLatitude: Double?
    var startLongitude: Double?
    var createdAt: Date
    var updatedAt: Date

    // Computed property for start location
    var startLocation: CLLocationCoordinate2D? {
        guard let lat = startLatitude, let lon = startLongitude else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    // Computed properties for progress tracking
    var completedStops: Int {
        stops.filter { $0.status == .delivered }.count
    }

    var totalStops: Int {
        stops.count
    }

    var progressPercentage: Double {
        guard totalStops > 0 else { return 0 }
        return Double(completedStops) / Double(totalStops)
    }

    var nextStop: Stop? {
        stops.first { $0.status == .pending || $0.status == .inProgress }
    }

    var formattedDistance: String {
        let kilometers = totalDistance / 1000.0
        return String(format: "%.1f km", kilometers)
    }

    var formattedDuration: String {
        let hours = Int(estimatedDuration) / 3600
        let minutes = (Int(estimatedDuration) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    init(
        id: UUID = UUID(),
        name: String,
        stops: [Stop] = [],
        isOptimized: Bool = false,
        totalDistance: Double = 0,
        estimatedDuration: TimeInterval = 0,
        startLocation: CLLocationCoordinate2D? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.stops = stops
        self.isOptimized = isOptimized
        self.totalDistance = totalDistance
        self.estimatedDuration = estimatedDuration
        self.startLatitude = startLocation?.latitude
        self.startLongitude = startLocation?.longitude
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    func setStartLocation(_ coordinate: CLLocationCoordinate2D) {
        startLatitude = coordinate.latitude
        startLongitude = coordinate.longitude
        updatedAt = Date()
    }
}
