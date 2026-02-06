//
//  NavigationApp.swift
//  RouteFlow
//
//  Created on 2026-02-06.
//

import Foundation

enum NavigationApp: String, CaseIterable, Codable {
    case appleMaps = "Apple Maps"
    case googleMaps = "Google Maps"
    case waze = "Waze"

    var urlScheme: String {
        switch self {
        case .appleMaps:
            return "http://maps.apple.com/"
        case .googleMaps:
            return "comgooglemaps://"
        case .waze:
            return "waze://"
        }
    }

    var universalLink: String {
        switch self {
        case .appleMaps:
            return "http://maps.apple.com/"
        case .googleMaps:
            return "https://www.google.com/maps/"
        case .waze:
            return "https://www.waze.com/ul"
        }
    }

    var icon: String {
        switch self {
        case .appleMaps:
            return "map.fill"
        case .googleMaps:
            return "map"
        case .waze:
            return "car.fill"
        }
    }
}
