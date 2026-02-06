//
//  MapControlsOverlay.swift
//  RouteFlow
//
//  Created on 2026-02-06.
//

import SwiftUI

struct MapControlsOverlay: View {
    let onLocationTap: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Button(action: onLocationTap) {
                Image(systemName: "location.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.blue)
                    .frame(width: 44, height: 44)
                    .background(.regularMaterial)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
            }
        }
    }
}
