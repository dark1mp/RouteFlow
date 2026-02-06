//
//  DeliveryStatus.swift
//  RouteFlow
//
//  Created on 2026-02-06.
//

import Foundation
import SwiftUI

enum DeliveryStatus: String, Codable, CaseIterable {
    case pending = "Pending"
    case inProgress = "In Progress"
    case delivered = "Delivered"
    case failed = "Failed"
    case skipped = "Skipped"

    var color: Color {
        switch self {
        case .pending:
            return .gray
        case .inProgress:
            return .blue
        case .delivered:
            return .green
        case .failed:
            return .red
        case .skipped:
            return .orange
        }
    }

    var icon: String {
        switch self {
        case .pending:
            return "clock"
        case .inProgress:
            return "arrow.right.circle"
        case .delivered:
            return "checkmark.circle.fill"
        case .failed:
            return "xmark.circle.fill"
        case .skipped:
            return "forward.circle.fill"
        }
    }
}
