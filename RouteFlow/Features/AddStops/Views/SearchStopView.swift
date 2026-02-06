//
//  SearchStopView.swift
//  RouteFlow
//
//  Created on 2026-02-06.
//

import SwiftUI
import MapKit

struct SearchStopView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: AddStopsViewModel
    @State private var isSearching = false
    @FocusState private var searchFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)

                    TextField("Search for address or location", text: $viewModel.searchText)
                        .textInputAutocapitalization(.none)
                        .focused($searchFocused)
                        .onChange(of: viewModel.searchText) { _, newValue in
                            if !newValue.isEmpty {
                                Task {
                                    await viewModel.searchLocations(newValue)
                                }
                            }
                        }

                    if !viewModel.searchText.isEmpty {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.searchText = ""
                                viewModel.searchResults = []
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding()

                if viewModel.isSearching {
                    // Loading state
                    VStack(spacing: 16) {
                        Spacer()
                        ProgressView()
                            .tint(.blue)
                        Text("Searching...")
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                } else if viewModel.searchResults.isEmpty {
                    if viewModel.searchText.isEmpty {
                        // Empty search state
                        VStack(spacing: 20) {
                            Spacer()

                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 48))
                                .foregroundColor(.gray.opacity(0.5))

                            Text("Search for a location")
                                .font(.headline)
                                .foregroundColor(.secondary)

                            Text("Enter an address or business name to add a stop to your route")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)

                            Spacer()
                        }
                    } else {
                        // No results state
                        VStack(spacing: 20) {
                            Spacer()

                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 48))
                                .foregroundColor(.gray.opacity(0.5))

                            Text("No results found")
                                .font(.headline)
                                .foregroundColor(.secondary)

                            Text("Try searching for a different address or business name")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)

                            Spacer()
                        }
                    }
                } else {
                    // Results list
                    List {
                        ForEach(viewModel.searchResults, id: \.self) { mapItem in
                            Button {
                                if let mapItem = mapItem as? MKMapItem {
                                    let identifiable = IdentifiableMapItem(mapItem: mapItem)
                                    viewModel.selectedLocation = identifiable
                                    
                                    // Show confirmation sheet
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        dismiss()
                                    }
                                }
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "mappin.circle.fill")
                                            .foregroundColor(.blue)
                                            .font(.system(size: 20))

                                        VStack(alignment: .leading, spacing: 2) {
                                            if let name = mapItem.name, !name.isEmpty {
                                                Text(name)
                                                    .font(.headline)
                                                    .foregroundColor(.primary)
                                            }

                                            Text(formatAddress(from: mapItem.placemark))
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .lineLimit(2)
                                        }

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.secondary)
                                            .font(.caption)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
                        }
                    }
                    .listStyle(.plain)
                    .transition(.opacity)
                }

                Spacer()

                // Close button
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.systemGray6))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Search Location")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                searchFocused = true
            }
        }
    }

    private func formatAddress(from placemark: CLPlacemark) -> String {
        var components: [String] = []

        if let number = placemark.subThoroughfare {
            components.append(number)
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

        return components.joined(separator: ", ")
    }
}
