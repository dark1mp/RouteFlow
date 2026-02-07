//
//  IdentifiableMapItem.swift
//  RouteFlow
//

import MapKit

struct IdentifiableMapItem: Identifiable {
    let id = UUID()
    let mapItem: MKMapItem
}
