//
//  NavigationAppSelectorView.swift
//  RouteFlow
//
//  Created on 2026-02-06.
//

import SwiftUI

struct NavigationAppSelectorView: View {
    let stop: Stop
    @Environment(\.dismiss) private var dismiss
    @AppStorage("preferredNavigationApp") private var preferredAppRaw: String = NavigationApp.appleMaps.rawValue
    @State private var rememberChoice = false
    @State private var errorMessage: String?
    @State private var showError = false

    private let navigationService = NavigationService()

    private var preferredApp: NavigationApp {
        NavigationApp(rawValue: preferredAppRaw) ?? .appleMaps
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Stop info
                VStack(spacing: 4) {
                    Text("Navigate to")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(stop.address)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                }
                .padding()

                Divider()

                // App options
                VStack(spacing: 0) {
                    ForEach(NavigationApp.allCases, id: \.self) { app in
                        Button {
                            openNavigation(with: app)
                        } label: {
                            HStack(spacing: 16) {
                                Image(systemName: app.icon)
                                    .font(.title3)
                                    .foregroundColor(.blue)
                                    .frame(width: 32)

                                Text(app.rawValue)
                                    .foregroundColor(.primary)

                                Spacer()

                                if preferredApp == app {
                                    Text("Default")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(8)
                                }

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                        }

                        Divider().padding(.leading, 60)
                    }
                }

                Spacer()

                // Remember choice toggle
                Toggle(isOn: $rememberChoice) {
                    Text("Remember my choice")
                        .font(.subheadline)
                }
                .padding()
                .onChange(of: rememberChoice) { _, newValue in
                    if !newValue {
                        // Reset to Apple Maps if they uncheck
                    }
                }
            }
            .navigationTitle("Open in...")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Navigation Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage ?? "Failed to open navigation app")
            }
        }
    }

    private func openNavigation(with app: NavigationApp) {
        if rememberChoice {
            preferredAppRaw = app.rawValue
        }

        Task {
            do {
                try await navigationService.openNavigation(to: stop, using: app)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}
