//
//  MainMapView.swift
//  RouteFlow
//
//  Created on 2026-02-06.
//

import SwiftUI
import SwiftData
import MapKit

struct MainMapView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var locationService: LocationService
    @StateObject private var viewModel: MainMapViewModel
    @State private var mapPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var selectedStop: Stop?
    @State private var showSearch = false
    @State private var showSideMenu = false
    @State private var showCreateRoute = true
    @State private var sheetDetent: PresentationDetent = .fraction(0.35)

    init(locationService: LocationService, modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: MainMapViewModel(locationService: locationService, modelContext: modelContext))
    }

    var body: some View {
        ZStack {
            // Layer 1: Full-screen map
            mapLayer
                .ignoresSafeArea()

            // Layer 2: Overlays
            VStack(spacing: 0) {
                // Top bar: hamburger + spacer + controls
                HStack(alignment: .top) {
                    // Hamburger menu
                    Button {
                        showSideMenu = true
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(width: 44, height: 44)
                            .background(.regularMaterial)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                    }

                    Spacer()

                    // Map controls
                    MapControlsOverlay(onLocationTap: centerOnUserLocation)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                Spacer()

                // Search bar above the bottom sheet
                MapSearchBarView(onTap: { showSearch = true })
                    .padding(.bottom, 8)
            }
        }
        .sheet(isPresented: .constant(true)) {
            StopsBottomSheetView(
                viewModel: viewModel.stopsViewModel,
                onAddStopTap: { showSearch = true }
            )
            .presentationDetents([.fraction(0.35), .medium, .large], selection: $sheetDetent)
            .presentationDragIndicator(.visible)
            .presentationBackgroundInteraction(.enabled(upThrough: .medium))
            .interactiveDismissDisabled()
        }
        .fullScreenCover(isPresented: $showSearch) {
            SearchStopView(viewModel: viewModel.stopsViewModel)
        }
        .fullScreenCover(isPresented: $showCreateRoute) {
            CreateRouteView { name, date in
                viewModel.createRoute(name: name, date: date)
            }
            .interactiveDismissDisabled()
        }
        .sheet(isPresented: $showSideMenu) {
            SideMenuView(onNewRoute: {
                showSideMenu = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    viewModel.startNewRoute()
                    showCreateRoute = true
                }
            })
        }
        .sheet(item: $selectedStop) { stop in
            StopDetailView(viewModel: viewModel.stopsViewModel, stop: stop)
        }
        .onChange(of: viewModel.stopsViewModel.route.stops.count) { _, _ in
            updateCameraToFitStops()
        }
    }

    // MARK: - Map Layer

    private var mapLayer: some View {
        Map(position: $mapPosition) {
            ForEach(viewModel.stopsViewModel.route.stops) { stop in
                Annotation("", coordinate: stop.coordinate) {
                    Button {
                        selectedStop = stop
                    } label: {
                        StopAnnotationView(stop: stop)
                    }
                }
            }
        }
        .mapControls {
            // Hide default controls since we have custom ones
        }
    }

    // MARK: - Actions

    private func centerOnUserLocation() {
        if let location = locationService.currentLocation {
            mapPosition = .region(MKCoordinateRegion(
                center: location,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        }
    }

    private func updateCameraToFitStops() {
        let stops = viewModel.stopsViewModel.route.stops
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

        withAnimation {
            mapPosition = .region(MKCoordinateRegion(center: center, span: span))
        }
    }
}

// MARK: - MainMapViewModel

@MainActor
final class MainMapViewModel: ObservableObject {
    @Published var stopsViewModel: AddStopsViewModel
    private let locationService: LocationService
    private let modelContext: ModelContext

    init(locationService: LocationService, modelContext: ModelContext) {
        self.locationService = locationService
        self.modelContext = modelContext
        self.stopsViewModel = AddStopsViewModel(
            locationService: locationService,
            modelContext: modelContext
        )
    }

    func createRoute(name: String, date: Date) {
        let route = Route(name: name, createdAt: date)
        modelContext.insert(route)
        stopsViewModel = AddStopsViewModel(
            route: route,
            locationService: locationService,
            modelContext: modelContext
        )
    }

    func startNewRoute() {
        stopsViewModel = AddStopsViewModel(
            locationService: locationService,
            modelContext: modelContext
        )
    }
}
