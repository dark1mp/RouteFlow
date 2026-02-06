//
//  AddStopsViewModel.swift
//  RouteFlow
//
//  Created on 2026-02-06.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation

@MainActor
final class AddStopsViewModel: ObservableObject {
    @Published var route: Route
    @Published var searchText = ""
    @Published var searchResults: [MKMapItem] = []
    @Published var isSearching = false
    @Published var selectedLocation: IdentifiableMapItem?
    @Published var stopNotes = ""

    private let geocodingService: GeocodingService
    private let locationService: LocationService

    init(route: Route, geocodingService: GeocodingService = GeocodingService(), locationService: LocationService) {
        self.route = route
        self.geocodingService = geocodingService
        self.locationService = locationService
    }

    func searchLocations(_ query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }

        isSearching = true
        defer { isSearching = false }

        do {
            let region = MKCoordinateRegion(
                center: locationService.currentLocation ?? CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
            )

            searchResults = try await geocodingService.searchLocations(query, region: region)
        } catch {
            print("Search error: \(error.localizedDescription)")
            searchResults = []
        }
    }

    func addStop(from identifiableItem: IdentifiableMapItem, notes: String = "") {
        let mapItem = identifiableItem.mapItem
        let address = formatAddress(from: mapItem)
        let coordinate = mapItem.placemark.coordinate

        let newStop = Stop(
            address: address,
            coordinate: coordinate,
            notes: notes,
            status: .pending,
            sequenceNumber: route.stops.count + 1
        )

        route.stops.append(newStop)
        route.updatedAt = Date()

        // Clear selection and notes
        selectedLocation = nil
        stopNotes = ""
        searchText = ""
        searchResults = []
    }

    func removeStop(_ stop: Stop) {
        route.stops.removeAll { $0.id == stop.id }
        resequenceStops()
        route.updatedAt = Date()
    }

    private func resequenceStops() {
        for (index, stop) in route.stops.enumerated() {
            stop.sequenceNumber = index + 1
        }
    }

    private func formatAddress(from mapItem: MKMapItem) -> String {
        let placemark = mapItem.placemark
        var components: [String] = []

        if let name = mapItem.name, !name.isEmpty {
            components.append(name)
        } else {
            if let number = placemark.subThoroughfare {
                components.append(number)
            }
            if let street = placemark.thoroughfare {
                components.append(street)
            }
        }

        if let city = placemark.locality {
            components.append(city)
        }

        return components.joined(separator: ", ")
    }
}
