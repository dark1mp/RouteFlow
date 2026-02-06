//
//  StopAnnotationView.swift
//  RouteFlow
//
//  Created on 2026-02-06.
//

import SwiftUI
import MapKit

struct StopAnnotationView: View {
    let stop: Stop

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(stop.status.color)
                    .frame(width: 36, height: 36)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)

                if stop.sequenceNumber > 0 {
                    Text("\(stop.sequenceNumber)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "mappin")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
            }

            // Pin stem
            Rectangle()
                .fill(stop.status.color)
                .frame(width: 3, height: 12)
        }
    }
}

#Preview {
    let stop = Stop(
        address: "123 Main St",
        coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        notes: "Brown door",
        status: .pending,
        sequenceNumber: 1
    )

    return StopAnnotationView(stop: stop)
        .padding()
}
