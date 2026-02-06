//
//  CreateRouteView.swift
//  RouteFlow
//
//  Created on 2026-02-06.
//

import SwiftUI

struct CreateRouteView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var routeName = ""
    @State private var selectedDate: RouteDate = .today
    @State private var customDate = Date()
    @State private var showDatePicker = false

    let onConfirm: (String, Date) -> Void

    enum RouteDate {
        case today, tomorrow, custom
    }

    private var resolvedDate: Date {
        switch selectedDate {
        case .today:
            return Date()
        case .tomorrow:
            return Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        case .custom:
            return customDate
        }
    }

    private var todayFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE dd MMM"
        return formatter.string(from: Date())
    }

    private var tomorrowFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE dd MMM"
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        return formatter.string(from: tomorrow)
    }

    private var placeholderName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: resolvedDate)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Close button
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(width: 32, height: 32)
            }
            .padding(.top, 16)
            .padding(.leading, 16)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Title
                    Text("Create route")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal)

                    // Route name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Route name (optional)")
                            .font(.subheadline)
                            .foregroundColor(.blue)

                        TextField(placeholderName, text: $routeName)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    // Select date
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select date")
                            .font(.subheadline)
                            .foregroundColor(.blue)

                        // Today
                        dateOption(
                            label: "Today",
                            detail: todayFormatted,
                            isSelected: selectedDate == .today
                        ) {
                            selectedDate = .today
                            showDatePicker = false
                        }

                        // Tomorrow
                        dateOption(
                            label: "Tomorrow",
                            detail: tomorrowFormatted,
                            isSelected: selectedDate == .tomorrow
                        ) {
                            selectedDate = .tomorrow
                            showDatePicker = false
                        }

                        // Pick a date
                        Button {
                            selectedDate = .custom
                            showDatePicker = true
                        } label: {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.secondary)
                                Text("Pick a date")
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedDate == .custom {
                                    let formatter = DateFormatter()
                                    let _ = formatter.dateFormat = "dd MMM yyyy"
                                    Text(formatter.string(from: customDate))
                                        .foregroundColor(.blue)
                                } else {
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)

                        if showDatePicker {
                            DatePicker(
                                "Select date",
                                selection: $customDate,
                                in: Date()...,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.horizontal)

                    // Quick start options
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick start options")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .padding(.horizontal)

                        Button {
                            // Coming soon
                        } label: {
                            HStack {
                                Image(systemName: "mappin.and.ellipse")
                                    .foregroundColor(.secondary)
                                Text("Pick past stops to carry over")
                                    .foregroundColor(.gray)
                                Spacer()
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.gray.opacity(0.4), lineWidth: 1.5)
                                    .frame(width: 22, height: 22)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        .disabled(true)
                        .padding(.horizontal)
                    }
                    .padding(.horizontal)
                }
            }

            Spacer()

            // Confirm button
            Button {
                let name = routeName.isEmpty ? placeholderName : routeName
                onConfirm(name, resolvedDate)
                dismiss()
            } label: {
                Text("Confirm")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }

    private func dateOption(label: String, detail: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.secondary)

                Text(label)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                Text(detail)
                    .foregroundColor(.blue.opacity(0.7))

                Spacer()

                Circle()
                    .strokeBorder(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 6 : 1.5)
                    .frame(width: 22, height: 22)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}
