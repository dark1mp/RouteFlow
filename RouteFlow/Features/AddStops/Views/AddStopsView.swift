//
//  AddStopsView.swift
//  RouteFlow
//

import SwiftUI
import MapKit
import SwiftData

struct AddStopsView: View {
    @ObservedObject var viewModel: AddStopsViewModel
    @State var route: Route
    @State private var showSearch = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Map(position: $viewModel.mapCameraPosition) {
                    ForEach(route.stops, id: \.id) { stop in
                        Marker("Stop \(route.stops.firstIndex(of: stop) ?? 0 + 1)", coordinate: stop.coordinate)
                            .tint(.blue)
                    }
                }
                .frame(height: 250)

                VStack(spacing: 12) {
                    HStack {
                        Text("Stops (\(route.stops.count))")
                            .font(.headline)
                        Spacer()
                        Button { showSearch = true } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "plus.circle.fill")
                                Text("Add")
                            }
                            .padding(8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(6)
                        }
                    }
                    .padding()

                    if route.stops.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "mappin.circle")
                                .font(.system(size: 48))
                                .foregroundColor(.gray)
                            Text("No stops yet")
                                .font(.headline)
                            Text("Add a stop to begin planning your route")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                    } else {
                        List {
                            ForEach(Array(route.stops.enumerated()), id: \.element.id) { index, stop in
                                HStack(spacing: 12) {
                                    VStack(alignment: .center) {
                                        Text("\(index + 1)").font(.headline).foregroundColor(.white)
                                    }
                                    .frame(width: 32, height: 32)
                                    .background(Color.blue)
                                    .cornerRadius(16)

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

                                    VStack(alignment: .trailing) {
                                        Image(systemName: "circle.fill")
                                            .font(.caption)
                                            .foregroundColor(statusColor(stop.status))
                                    }
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        viewModel.removeStop(stop)
                                    } label: {
                                        Image(systemName: "trash.fill")
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showSearch) {
            SearchStopView(viewModel: viewModel)
        }
    }

    private func statusColor(_ status: DeliveryStatus) -> Color {
        switch status {
        case .pending: return .gray
        case .inProgress: return .orange
        case .delivered: return .green
        case .failed: return .red
        case .skipped: return .gray
        }
    }
}
