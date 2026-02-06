//
//  CLLocationCoordinate2D+Extensions.swift
//  RouteFlow
//
//  Created on 2026-02-06.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D {
    /// Calculate distance to another coordinate in meters
    func distance(to coordinate: CLLocationCoordinate2D) -> Double {
        let location1 = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let location2 = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return location1.distance(from: location2) // Returns meters
    }

    /// Check if coordinate is valid
    var isValid: Bool {
        return latitude >= -90 && latitude <= 90 && longitude >= -180 && longitude <= 180
    }
}

// Note: CLLocationCoordinate2D already conforms to Equatable in iOS 16+

