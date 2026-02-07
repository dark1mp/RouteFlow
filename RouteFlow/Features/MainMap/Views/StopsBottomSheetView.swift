//
//  StopsBottomSheetView.swift
//  RouteFlow
//
//  Created on 2026-02-06.
//

import SwiftUI

struct StopsBottomSheetView: View {
    @ObservedObject var viewModel: AddStopsViewModel
    let onAddStopTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.route.stops.isEmpty {
                emptyState
            } else {
                populatedState
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 8)

            // Dashed border empty area
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [8, 6]))
                .foregroundColor(.gray.opacity(0.4))
                .frame(height: 90)
                .overlay {
                    VStack(spacing: 8) {
                        Image(systemName: "plus.dashed")
                            .font(.system(size: 28))
                            .foregroundColor(.gray.opacity(0.5))

                        Text("Add your first stops to start creating your route")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)
                }
                .padding(.horizontal)

            // Add stop button
            Button(action: onAddStopTap) {
                HStack {
                    Image(systemName: "plus")
                        .fontWeight(.semibold)
                    Text("Add stop")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding(.horizontal)

            // Copy from past route (disabled for now)
            Button {
                // Coming soon
            } label: {
                Text("Copy stops from a past route")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .disabled(true)

            Spacer()
        }
    }

    // MARK: - Populated State

    private var populatedState: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("\(viewModel.route.stops.count) Stop\(viewModel.route.stops.count == 1 ? "" : "s")")
                    .font(.headline)

                Spacer()

                Button(action: onAddStopTap) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Add stop")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)

            Divider()

            // Stop list
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.route.stops) { stop in
                        StopRowInList(stop: stop, onDelete: {
                            withAnimation {
                                viewModel.removeStop(stop)
                            }
                        })
                        Divider().padding(.leading, 60)
                    }
                }
            }
        }
    }
}

// MARK: - Stop Row Component
struct StopRowInList: View {
    let stop: Stop
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Sequence number badge
            ZStack {
                Circle()
                    .fill(statusColor(stop.status))
                    .frame(width: 36, height: 36)
                Text("\(stop.sequenceNumber)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            // Stop info
            VStack(alignment: .leading, spacing: 3) {
                Text(stop.address)
                    .font(.subheadline)
                    .fontWeight(.medium)
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
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.gray.opacity(0.5))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
    
    private func statusColor(_ status: DeliveryStatus) -> Color {
        switch status {
        case .pending: return .blue
        case .inProgress: return .orange
        case .delivered: return .green
        case .failed: return .red
        case .skipped: return .gray
        }
    }
}
