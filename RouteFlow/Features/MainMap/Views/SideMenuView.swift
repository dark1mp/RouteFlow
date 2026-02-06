//
//  SideMenuView.swift
//  RouteFlow
//
//  Created on 2026-02-06.
//

import SwiftUI

struct SideMenuView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showRouteHistory = false
    var onNewRoute: (() -> Void)? = nil

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if let onNewRoute {
                        Button {
                            onNewRoute()
                        } label: {
                            Label("New Route", systemImage: "plus.circle")
                        }
                    }

                    Button {
                        showRouteHistory = true
                    } label: {
                        Label("My Routes", systemImage: "map")
                    }

                    Label("Settings", systemImage: "gearshape")
                        .foregroundColor(.secondary)
                }

                Section {
                    HStack {
                        Text("RouteFlow")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("v1.0")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("RouteFlow")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .navigationDestination(isPresented: $showRouteHistory) {
                RouteHistoryView()
            }
        }
    }
}
