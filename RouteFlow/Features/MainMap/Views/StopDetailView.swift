//
//  StopDetailView.swift
//  RouteFlow
//
//  Created on 2026-02-06.
//

import SwiftUI
import MapKit

struct StopDetailView: View {
    @ObservedObject var viewModel: AddStopsViewModel
    let stop: Stop
    @Environment(\.dismiss) private var dismiss
    @State private var editedNotes: String
    @State private var showRemoveConfirmation = false

    init(viewModel: AddStopsViewModel, stop: Stop) {
        self.viewModel = viewModel
        self.stop = stop
        _editedNotes = State(initialValue: stop.notes)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Mini map
                Map {
                    Annotation("", coordinate: stop.coordinate) {
                        StopAnnotationView(stop: stop)
                    }
                }
                .frame(height: 160)
                .allowsHitTesting(false)

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Status badges
                        HStack(spacing: 8) {
                            statusBadge(
                                color: stop.status.color,
                                text: stop.status.rawValue
                            )

                            Spacer()

                            if stop.status == .pending {
                                Text("Stop #\(stop.sequenceNumber)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 16)

                        // Address
                        Text(stop.address)
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                            .padding(.top, 12)

                        // Notes section
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "note.text")
                                    .foregroundColor(.secondary)
                                Text("Notes")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            TextField("Add delivery notes...", text: $editedNotes, axis: .vertical)
                                .lineLimit(2...4)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .onChange(of: editedNotes) { _, newValue in
                                    stop.notes = newValue
                                    stop.updatedAt = Date()
                                }
                        }
                        .padding()

                        Divider()

                        // Delivery status
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "shippingbox")
                                    .foregroundColor(.secondary)
                                Text("Delivery status")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            ForEach(DeliveryStatus.allCases, id: \.self) { status in
                                Button {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        stop.updateStatus(status)
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: status.icon)
                                            .foregroundColor(status.color)
                                            .frame(width: 24)

                                        Text(status.rawValue)
                                            .foregroundColor(.primary)

                                        Spacer()

                                        if stop.status == status {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.blue)
                                        } else {
                                            Circle()
                                                .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1.5)
                                                .frame(width: 22, height: 22)
                                        }
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 12)
                                    .background(
                                        stop.status == status
                                            ? status.color.opacity(0.08)
                                            : Color.clear
                                    )
                                    .cornerRadius(10)
                                }
                            }
                        }
                        .padding()

                        Divider()

                        // Actions
                        VStack(spacing: 0) {
                            Button {
                                showRemoveConfirmation = true
                            } label: {
                                HStack {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                    Text("Remove stop")
                                        .foregroundColor(.red)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                            }
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Remove stop?", isPresented: $showRemoveConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Remove", role: .destructive) {
                    viewModel.removeStop(stop)
                    dismiss()
                }
            } message: {
                Text("This will remove \"\(stop.address)\" from your route.")
            }
        }
    }

    private func statusBadge(color: Color, text: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(color.opacity(0.1))
        .cornerRadius(16)
    }
}
