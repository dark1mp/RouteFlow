//
//  MapWithPinsView.swift
//  RouteFlow
//
//  Created on 2026-02-06.
//

import SwiftUI
import MapKit

struct MapWithPinsView: View {
    let stops: [Stop]
    let showRoute: Bool
    @State private var position: MapCameraPosition
    @State private var selectedStop: Stop?

    init(stops: [Stop], showRoute: Bool = false) {
        self.stops = stops
        self.showRoute = showRoute

        // Initialize camera position
        if let firstStop = stops.first {
            _position = State(initialValue: .region(MKCoordinateRegion(
                center: firstStop.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )))
        } else {
            _position = State(initialValue: .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )))
        }
    }

    var body: some View {
        Map(position: $position) {
            ForEach(stops) { stop in
                Annotation("", coordinate: stop.coordinate) {
                    Button {
                        selectedStop = stop
                    } label: {
                        StopAnnotationView(stop: stop)
                    }
                }
            }
        }
        .onAppear {
            updateCameraToFitStops()
        }
        .onChange(of: stops) { _, _ in
            updateCameraToFitStops()
        }
        .sheet(item: $selectedStop) { stop in
            StopDetailSheet(stop: stop)
        }
    }

    private func updateCameraToFitStops() {
        guard !stops.isEmpty else { return }

        let coordinates = stops.map { $0.coordinate }
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

        position = .region(MKCoordinateRegion(center: center, span: span))
    }
}

// Temporary placeholder for stop detail sheet
struct StopDetailSheet: View {
    let stop: Stop
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text(stop.address)
                    .font(.title3)

                HStack {
                    Image(systemName: stop.status.icon)
                        .foregroundColor(stop.status.color)
                    Text(stop.status.rawValue)
                        .foregroundColor(stop.status.color)
                }

                if !stop.notes.isEmpty {
                    Text(stop.notes)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .navigationTitle("Stop #\(stop.sequenceNumber)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    let stops = [
        Stop(address: "123 Main St", coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), sequenceNumber: 1),
        Stop(address: "456 Oak Ave", coordinate: CLLocationCoordinate2D(latitude: 37.7849, longitude: -122.4094), sequenceNumber: 2),
        Stop(address: "789 Pine Rd", coordinate: CLLocationCoordinate2D(latitude: 37.7649, longitude: -122.4294), sequenceNumber: 3)
    ]

    return MapWithPinsView(stops: stops)
}
