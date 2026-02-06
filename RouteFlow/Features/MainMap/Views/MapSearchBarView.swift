//
//  MapSearchBarView.swift
//  RouteFlow
//
//  Created on 2026-02-06.
//

import SwiftUI

struct MapSearchBarView: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 18))

                Text("Tap to add stops")
                    .foregroundColor(.secondary)
                    .font(.body)

                Spacer()

                Image(systemName: "line.3.horizontal.decrease.circle")
                    .foregroundColor(.secondary)
                    .font(.system(size: 18))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(.regularMaterial)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
        }
        .padding(.horizontal, 16)
    }
}
