//
//  AddStopsView.swift
//  RouteFlow
//
//  Created on 2026-02-06.
//

import SwiftUI
import MapKit

// Wrapper to make MKMapItem Identifiable
struct IdentifiableMapItem: Identifiable {
    let id = UUID()
    let mapItem: MKMapItem
}

struct AddStopsView: View {
    @StateObject private var viewModel: AddStopsViewModel
    @EnvironmentObject private var locationService: LocationService
    @Environment(\.dismiss) private var dismiss
    @State private var showSearch = false

    init(route: Route, locationService: LocationService) {
        _viewModel = StateObject(wrappedValue: AddStopsViewModel(route: route, locationService: locationService))
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Map with all stops
                if !viewModel.route.stops.isEmpty {
                    MapWithPinsView(stops: viewModel.route.stops)
                        .ignoresSafeArea(edges: .bottom)
                } else {
                    emptyMapView
                }

                // Stop list overlay
                if !viewModel.route.stops.isEmpty {
                    stopListCard
                        .transition(.move(edge: .bottom))
                }
            }
            .navigationTitle("Add Stops")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showSearch = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showSearch) {
                SearchStopView(viewModel: viewModel)
            }
        }
    }

    private var emptyMapView: some View {
        VStack(spacing: 20) {
            Image(systemName: "map")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("No Stops Yet")
                .font(.title2)
                .fontWeight(.bold)

            Text("Add your first delivery stop to get started")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showSearch = true
            } label: {
                Label("Add Stop", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }

    private var stopListCard: some View {
        VStack(spacing: 0) {
            HStack {
                Text("\(viewModel.route.stops.count) Stops")
                    .font(.headline)

                Spacer()

                Button {
                    showSearch = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
            }
            .padding()
            .background(Color(.systemBackground))

            Divider()

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.route.stops) { stop in
                        StopRowInList(stop: stop, onDelete: {
                            withAnimation {
                                viewModel.removeStop(stop)
                            }
                        })
                    }
                }
            }
            .frame(maxHeight: 300)
        }
        .background(Color(.systemBackground))
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
    }
}

// MARK: - Stop Row
struct StopRowInList: View {
    let stop: Stop
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Sequence number
            ZStack {
                Circle()
                    .fill(stop.status.color.opacity(0.2))
                    .frame(width: 36, height: 36)

                Text("\(stop.sequenceNumber)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(stop.status.color)
            }

            // Address and notes
            VStack(alignment: .leading, spacing: 4) {
                Text(stop.address)
                    .font(.body)
                    .lineLimit(1)

                if !stop.notes.isEmpty {
                    Text(stop.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Delete button
            Button {
                onDelete()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .font(.title3)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// MARK: - Search View
struct SearchStopView: View {
    @ObservedObject var viewModel: AddStopsViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)

                    TextField("Search address or place", text: $viewModel.searchText)
                        .focused($isSearchFocused)
                        .textFieldStyle(.plain)
                        .autocorrectionDisabled()
                        .onChange(of: viewModel.searchText) { newValue in
                            Task {
                                await viewModel.searchLocations(newValue)
                            }
                        }

                    if !viewModel.searchText.isEmpty {
                        Button {
                            viewModel.searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding()

                // Results
                if viewModel.isSearching {
                    ProgressView()
                        .padding()
                    Spacer()
                } else if viewModel.searchResults.isEmpty && !viewModel.searchText.isEmpty {
                    Text("No results found")
                        .foregroundColor(.secondary)
                        .padding()
                    Spacer()
                } else {
                    List(viewModel.searchResults, id: \.self) { mapItem in
                        Button {
                            viewModel.selectedLocation = IdentifiableMapItem(mapItem: mapItem)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(mapItem.name ?? "Unknown")
                                    .font(.body)

                                if let address = formatPlacemark(mapItem.placemark) {
                                    Text(address)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Stop")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $viewModel.selectedLocation) { identifiableItem in
                AddStopDetailView(identifiableMapItem: identifiableItem, viewModel: viewModel, dismiss: dismiss)
            }
            .onAppear {
                isSearchFocused = true
            }
        }
    }

    private func formatPlacemark(_ placemark: MKPlacemark) -> String? {
        var components: [String] = []

        if let street = placemark.thoroughfare {
            if let number = placemark.subThoroughfare {
                components.append("\(number) \(street)")
            } else {
                components.append(street)
            }
        }

        if let city = placemark.locality {
            components.append(city)
        }

        return components.isEmpty ? nil : components.joined(separator: ", ")
    }
}

// MARK: - Add Stop Detail
struct AddStopDetailView: View {
    let identifiableMapItem: IdentifiableMapItem
    @ObservedObject var viewModel: AddStopsViewModel
    let dismiss: DismissAction
    @Environment(\.dismiss) private var dismissSelf

    var mapItem: MKMapItem {
        identifiableMapItem.mapItem
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Location") {
                    Text(mapItem.name ?? "Unknown")
                        .font(.headline)

                    if let address = formatAddress() {
                        Text(address)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                Section("Notes") {
                    TextField("Delivery instructions (optional)", text: $viewModel.stopNotes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Stop")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismissSelf()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        viewModel.addStop(from: identifiableMapItem, notes: viewModel.stopNotes)
                        dismissSelf()
                        dismiss()
                    }
                }
            }
        }
    }

    private func formatAddress() -> String? {
        let placemark = mapItem.placemark
        var components: [String] = []

        if let street = placemark.thoroughfare {
            if let number = placemark.subThoroughfare {
                components.append("\(number) \(street)")
            } else {
                components.append(street)
            }
        }

        if let city = placemark.locality {
            components.append(city)
        }

        if let state = placemark.administrativeArea {
            components.append(state)
        }

        return components.isEmpty ? nil : components.joined(separator: ", ")
    }
}

// Helper for corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
