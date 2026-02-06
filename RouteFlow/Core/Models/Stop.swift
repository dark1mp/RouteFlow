//
//  Stop.swift
//  RouteFlow
//
//  Created on 2026-02-06.
//

import Foundation
import SwiftData
import CoreLocation

@Model
final class Stop {
    var id: UUID
    var address: String
    var latitude: Double
    var longitude: Double
    var notes: String
    var status: DeliveryStatus
    var sequenceNumber: Int
    var estimatedArrivalTime: Date?
    var actualArrivalTime: Date?
    var completionTime: Date?
    var createdAt: Date
    var updatedAt: Date

    // Computed property for coordinate
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    // Computed property for completion status
    var isCompleted: Bool {
        status == .delivered
    }

    // Computed property for display address
    var displayAddress: String {
        address
    }

    init(
        id: UUID = UUID(),
        address: String,
        coordinate: CLLocationCoordinate2D,
        notes: String = "",
        status: DeliveryStatus = .pending,
        sequenceNumber: Int = 0,
        estimatedArrivalTime: Date? = nil,
        actualArrivalTime: Date? = nil,
        completionTime: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.address = address
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.notes = notes
        self.status = status
        self.sequenceNumber = sequenceNumber
        self.estimatedArrivalTime = estimatedArrivalTime
        self.actualArrivalTime = actualArrivalTime
        self.completionTime = completionTime
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    func updateStatus(_ newStatus: DeliveryStatus) {
        status = newStatus
        updatedAt = Date()

        if newStatus == .delivered {
            completionTime = Date()
        }
    }
}
