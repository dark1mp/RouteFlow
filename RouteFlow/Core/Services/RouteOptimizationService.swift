//
//  RouteOptimizationService.swift
//  RouteFlow
//
//  Created on 2026-02-06.
//

import Foundation
import CoreLocation

protocol RouteOptimizationServiceProtocol {
    func optimizeRoute(stops: [Stop], startLocation: CLLocationCoordinate2D) async -> [Stop]
    func calculateTotalDistance(stops: [Stop], from startLocation: CLLocationCoordinate2D?) -> Double
    func calculateETA(for stop: Stop, from previousLocation: CLLocationCoordinate2D?, startTime: Date) -> Date
}

final class RouteOptimizationService: RouteOptimizationServiceProtocol {

    private let averageSpeedMPS: Double = 13.4 // 30 mph in meters/second
    private let stopDuration: TimeInterval = 180 // 3 minutes per stop

    /// Optimize route using Nearest Neighbor + 2-opt algorithm
    func optimizeRoute(stops: [Stop], startLocation: CLLocationCoordinate2D) async -> [Stop] {
        guard stops.count > 1 else {
            // If only one stop, just return it with sequence number
            if let stop = stops.first {
                stop.sequenceNumber = 1
            }
            return stops
        }

        // Step 1: Nearest Neighbor (greedy initial solution)
        var optimized = nearestNeighborOptimization(stops: stops, start: startLocation)

        // Step 2: 2-opt improvement (refine solution)
        optimized = twoOptImprovement(stops: optimized, startLocation: startLocation)

        // Assign sequence numbers and calculate ETAs
        var currentTime = Date()
        var currentLocation = startLocation

        for (index, stop) in optimized.enumerated() {
            stop.sequenceNumber = index + 1
            stop.estimatedArrivalTime = calculateETA(for: stop, from: currentLocation, startTime: currentTime)

            // Update for next iteration
            currentTime = stop.estimatedArrivalTime ?? currentTime
            currentLocation = stop.coordinate
        }

        return optimized
    }

    /// Calculate total distance for a route
    func calculateTotalDistance(stops: [Stop], from startLocation: CLLocationCoordinate2D?) -> Double {
        guard !stops.isEmpty else { return 0 }

        var totalDistance: Double = 0
        var previousLocation = startLocation ?? stops.first?.coordinate

        for stop in stops {
            if let prev = previousLocation {
                totalDistance += prev.distance(to: stop.coordinate)
            }
            previousLocation = stop.coordinate
        }

        return totalDistance
    }

    /// Calculate estimated time of arrival
    func calculateETA(for stop: Stop, from previousLocation: CLLocationCoordinate2D?, startTime: Date) -> Date {
        guard let previous = previousLocation else {
            return startTime
        }

        let distance = previous.distance(to: stop.coordinate)
        let travelTime = distance / averageSpeedMPS
        let totalTime = travelTime + stopDuration

        return startTime.addingTimeInterval(totalTime)
    }

    // MARK: - Private Optimization Methods

    /// Nearest Neighbor algorithm - O(n²)
    private func nearestNeighborOptimization(stops: [Stop], start: CLLocationCoordinate2D) -> [Stop] {
        var unvisited = stops
        var route: [Stop] = []
        var currentLocation = start

        while !unvisited.isEmpty {
            let nearest = findNearestStop(to: currentLocation, in: unvisited)
            route.append(nearest)
            unvisited.removeAll { $0.id == nearest.id }
            currentLocation = nearest.coordinate
        }

        return route
    }

    /// Find nearest stop to given location
    private func findNearestStop(to location: CLLocationCoordinate2D, in stops: [Stop]) -> Stop {
        var nearestStop = stops[0]
        var shortestDistance = location.distance(to: stops[0].coordinate)

        for stop in stops.dropFirst() {
            let distance = location.distance(to: stop.coordinate)
            if distance < shortestDistance {
                shortestDistance = distance
                nearestStop = stop
            }
        }

        return nearestStop
    }

    /// 2-opt improvement algorithm
    private func twoOptImprovement(stops: [Stop], startLocation: CLLocationCoordinate2D) -> [Stop] {
        var improved = stops
        var improvementFound = true

        // Keep improving until no more improvements found
        while improvementFound {
            improvementFound = false

            for i in 0..<improved.count - 1 {
                for j in i + 1..<improved.count {
                    let newRoute = twoOptSwap(route: improved, i: i, j: j)
                    let currentDistance = calculateTotalDistance(stops: improved, from: startLocation)
                    let newDistance = calculateTotalDistance(stops: newRoute, from: startLocation)

                    if newDistance < currentDistance {
                        improved = newRoute
                        improvementFound = true
                    }
                }
            }
        }

        return improved
    }

    /// Perform 2-opt swap
    private func twoOptSwap(route: [Stop], i: Int, j: Int) -> [Stop] {
        var newRoute = route

        // Reverse the segment between i and j
        let segment = Array(newRoute[i...j].reversed())
        newRoute.replaceSubrange(i...j, with: segment)

        return newRoute
    }
}
