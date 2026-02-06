//
//  NavigationService.swift
//  RouteFlow
//
//  Created on 2026-02-06.
//

import Foundation
import UIKit
import CoreLocation

protocol NavigationServiceProtocol {
    func openNavigation(to stop: Stop, using app: NavigationApp) async throws
    func canOpenNavigationApp(_ app: NavigationApp) -> Bool
}

enum NavigationError: LocalizedError {
    case invalidURL
    case appNotInstalled(NavigationApp)
    case openFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Failed to create navigation URL"
        case .appNotInstalled(let app):
            return "\(app.rawValue) is not installed on this device"
        case .openFailed:
            return "Failed to open navigation app"
        }
    }
}

final class NavigationService: NavigationServiceProtocol {

    @MainActor
    func openNavigation(to stop: Stop, using app: NavigationApp) async throws {
        guard let url = buildNavigationURL(for: stop, app: app) else {
            throw NavigationError.invalidURL
        }

        // Try URL scheme first
        if UIApplication.shared.canOpenURL(url) {
            let success = await UIApplication.shared.open(url)
            if !success {
                throw NavigationError.openFailed
            }
        } else {
            // Fallback to universal link
            guard let universalURL = buildUniversalURL(for: stop, app: app) else {
                throw NavigationError.invalidURL
            }

            let success = await UIApplication.shared.open(universalURL)
            if !success {
                throw NavigationError.appNotInstalled(app)
            }
        }
    }

    func canOpenNavigationApp(_ app: NavigationApp) -> Bool {
        guard let url = URL(string: app.urlScheme) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }

    // MARK: - Private Methods

    private func buildNavigationURL(for stop: Stop, app: NavigationApp) -> URL? {
        let lat = stop.coordinate.latitude
        let lon = stop.coordinate.longitude

        switch app {
        case .appleMaps:
            // http://maps.apple.com/?daddr=37.7749,-122.4194
            return URL(string: "http://maps.apple.com/?daddr=\(lat),\(lon)")

        case .googleMaps:
            // comgooglemaps://?daddr=37.7749,-122.4194&directionsmode=driving
            return URL(string: "comgooglemaps://?daddr=\(lat),\(lon)&directionsmode=driving")

        case .waze:
            // waze://?ll=37.7749,-122.4194&navigate=yes
            return URL(string: "waze://?ll=\(lat),\(lon)&navigate=yes")
        }
    }

    private func buildUniversalURL(for stop: Stop, app: NavigationApp) -> URL? {
        let lat = stop.coordinate.latitude
        let lon = stop.coordinate.longitude

        switch app {
        case .appleMaps:
            return URL(string: "http://maps.apple.com/?daddr=\(lat),\(lon)")

        case .googleMaps:
            return URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(lat),\(lon)")

        case .waze:
            return URL(string: "https://www.waze.com/ul?ll=\(lat),\(lon)&navigate=yes")
        }
    }
}
