//
//  GeocodingService.swift
//  RouteFlow
//
//  Created on 2026-02-06.
//

import Foundation
import CoreLocation
import MapKit

enum GeocodingError: LocalizedError {
    case noResults
    case invalidAddress
    case serviceUnavailable

    var errorDescription: String? {
        switch self {
        case .noResults:
            return "No results found for the address"
        case .invalidAddress:
            return "The address provided is invalid"
        case .serviceUnavailable:
            return "Geocoding service is currently unavailable"
        }
    }
}

final class GeocodingService {
    private let geocoder = CLGeocoder()

    /// Convert address string to coordinates
    func geocodeAddress(_ address: String) async throws -> CLLocationCoordinate2D {
        do {
            let placemarks = try await geocoder.geocodeAddressString(address)

            guard let coordinate = placemarks.first?.location?.coordinate else {
                throw GeocodingError.noResults
            }

            return coordinate
        } catch {
            if error is GeocodingError {
                throw error
            }
            throw GeocodingError.serviceUnavailable
        }
    }

    /// Convert coordinates to address string
    func reverseGeocode(_ coordinate: CLLocationCoordinate2D) async throws -> String {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)

            guard let placemark = placemarks.first else {
                throw GeocodingError.noResults
            }

            return formatPlacemark(placemark)
        } catch {
            if error is GeocodingError {
                throw error
            }
            throw GeocodingError.serviceUnavailable
        }
    }

    /// Search for locations using MKLocalSearch
    func searchLocations(_ query: String, region: MKCoordinateRegion? = nil) async throws -> [MKMapItem] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query

        if let region = region {
            request.region = region
        }

        let search = MKLocalSearch(request: request)

        do {
            let response = try await search.start()
            return response.mapItems
        } catch {
            throw GeocodingError.serviceUnavailable
        }
    }

    // MARK: - Private Helpers

    private func formatPlacemark(_ placemark: CLPlacemark) -> String {
        var components: [String] = []

        if let streetNumber = placemark.subThoroughfare {
            components.append(streetNumber)
        }

        if let street = placemark.thoroughfare {
            components.append(street)
        }

        if let city = placemark.locality {
            components.append(city)
        }

        if let state = placemark.administrativeArea {
            components.append(state)
        }

        if let postalCode = placemark.postalCode {
            components.append(postalCode)
        }

        return components.joined(separator: ", ")
    }
}
