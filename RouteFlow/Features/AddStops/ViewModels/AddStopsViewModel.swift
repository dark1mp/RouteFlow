//
//  AddStopsViewModel.swift
//  RouteFlow
//
//  Created on 2026-02-06.
//

import Foundation
import SwiftUI
import SwiftData
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
    @Published var focusedStopID: UUID?
    @Published var mapCameraPosition: MapCameraPosition = .automatic

    private let geocodingService: GeocodingService
    private let locationService: LocationService
    private var modelContext: ModelContext?
    private var hasCreatedRoute = false

    init(route: Route, geocodingService: GeocodingService = GeocodingService(), locationService: LocationService, modelContext: ModelContext? = nil) {
        self.route = route
        self.geocodingService = geocodingService
        self.locationService = locationService
        self.modelContext = modelContext
        self.hasCreatedRoute = true
    }

    /// Initialize without a route — one will be created on first stop add
    init(locationService: LocationService, modelContext: ModelContext, geocodingService: GeocodingService = GeocodingService()) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let defaultName = "Route - \(formatter.string(from: Date()))"
        self.route = Route(name: defaultName)
        self.geocodingService = geocodingService
        self.locationService = locationService
        self.modelContext = modelContext
        self.hasCreatedRoute = false
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
        // Insert route into SwiftData on first stop add
        if !hasCreatedRoute, let modelContext {
            modelContext.insert(route)
            hasCreatedRoute = true
            try? modelContext.save()
        }

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

        // Save the updated route
        if let modelContext {
            try? modelContext.save()
        }

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
