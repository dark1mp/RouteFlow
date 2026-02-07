//
//  SearchStopView.swift
//  RouteFlow
//

import SwiftUI
import MapKit

struct SearchStopView: View {
    @ObservedObject var viewModel: AddStopsViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isSearchFocused: Bool
    @State private var showConfirm = false
    @State private var selectedMapItem: MKMapItem?

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    Text("Add Stop")
                        .font(.headline)
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2).foregroundColor(.gray)
                    }
                }
                .padding()

                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass").foregroundColor(.gray)
                    TextField("Search address...", text: $viewModel.searchText)
                        .focused($isSearchFocused)
                        .autocorrectionDisabled()
                        .onChange(of: viewModel.searchText) { _, newValue in
                            Task { await viewModel.searchLocations(newValue) }
                        }
                    if !viewModel.searchText.isEmpty {
                        Button(action: { viewModel.searchText = "" }) {
                            Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
                        }
                    }
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding()

                if viewModel.isSearching {
                    ProgressView().padding()
                } else if viewModel.searchResults.isEmpty && !viewModel.searchText.isEmpty {
                    Text("No results found").foregroundColor(.secondary).padding()
                } else if !viewModel.searchResults.isEmpty {
                    List(viewModel.searchResults, id: \.self) { mapItem in
                        Button(action: {
                            selectedMapItem = mapItem
                            showConfirm = true
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(mapItem.name ?? "Unknown")
                                    .font(.body).foregroundColor(.primary)
                                if let address = formatAddress(mapItem) {
                                    Text(address).font(.caption).foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
                Spacer()
            }

            if showConfirm, let mapItem = selectedMapItem {
                ZStack {
                    Color.black.opacity(0.3).ignoresSafeArea()
                    VStack(spacing: 16) {
                        HStack {
                            Text("Confirm Stop").font(.headline)
                            Spacer()
                            Button(action: { showConfirm = false }) {
                                Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(mapItem.name ?? "Unknown").font(.headline)
                            if let address = formatAddress(mapItem) {
                                Text(address).font(.caption).foregroundColor(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        TextField("Notes (optional)", text: $viewModel.stopNotes, axis: .vertical)
                            .lineLimit(3...5)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        
                        HStack(spacing: 12) {
                            Button("Cancel") { showConfirm = false }
                                .frame(maxWidth: .infinity)
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            
                            Button("Add Stop") {
                                viewModel.addStop(from: IdentifiableMapItem(mapItem: mapItem), notes: viewModel.stopNotes)
                                dismiss()
                            }
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .padding()
                }
            }
        }
        .onAppear { isSearchFocused = true }
    }

    private func formatAddress(_ mapItem: MKMapItem) -> String? {
        let p = mapItem.placemark
        var c: [String] = []
        if let s = p.thoroughfare {
            if let n = p.subThoroughfare { c.append("\(n) \(s)") } else { c.append(s) }
        }
        if let city = p.locality { c.append(city) }
        return c.isEmpty ? nil : c.joined(separator: ", ")
    }
}
