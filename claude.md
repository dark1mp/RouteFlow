# RouteFlow Development Guide

## Project Overview
RouteFlow is an iOS delivery route planning app built with SwiftUI, MapKit, and SwiftData.

## Project Structure
- Xcode project at: RouteFlow/RouteFlow.xcodeproj
- Source code at: RouteFlow/RouteFlow/
- GitHub: github.com/dark1mp/RouteFlow (branch: main)
- Bundle ID: com.canpolat.RouteFlow

## Technical Requirements
- Minimum deployment target: iOS 17.0 (iPhone 11 and newer — all supported)
- Language: Swift 5.9+
- UI Framework: SwiftUI
- Persistence: SwiftData (@Model)
- Maps: MapKit with MKMapItem for location search
- No third-party dependencies — Apple frameworks only

## Architecture
- MVVM pattern: Views → ViewModels → Services
- Features organized under Features/ (AddStops, MainMap)
- Shared components under Shared/Components/ and Shared/Views/
- Core models, services, and utilities under Core/

## Key Models
- **Route** (@Model): name, date, stops array, isOptimized, totalDistance, estimatedDuration
  - Computed: progressPercentage, nextStop, formattedDistance, formattedDuration
- **Stop** (@Model): address, latitude, longitude, notes, status, sequenceNumber
  - DeliveryStatus cases: .pending, .inProgress, .delivered, .failed, .skipped
  - Uses `stop.coordinate` (computed CLLocationCoordinate2D), **NOT** `stop.location`
  - Each DeliveryStatus has: color, icon properties
- **IdentifiableMapItem**: wrapper around MKMapItem for SwiftUI lists
- **NavigationApp**: enum (AppleMaps, GoogleMaps, Waze) with urlScheme, universalLink, icon

## Key Views & Flow
- RouteFlowApp → LaunchScreenView (1.8s splash) → MainMapView
- MainMapView: Map + hamburger menu + search bar + bottom sheet (StopsBottomSheetView)
- StopsBottomSheetView: "Add stop" button triggers `showSearch = true` via closure
- MainMapView has `.fullScreenCover(isPresented: $showSearch)` → SearchStopView
- SearchStopView: search field + results list + confirmation modal overlay
- AddStopsView: map + stop list (used separately from MainMapView flow)

### Data Flow
```
MainMapView
├── MainMapViewModel
│   └── AddStopsViewModel (for stop management)
│       ├── LocationService
│       ├── GeocodingService
│       └── ModelContext (SwiftData)
├── Sheets/Modals
│   ├── CreateRouteView (onConfirm → createRoute)
│   ├── SearchStopView (select location → addStop)
│   ├── StopDetailView (edit stop properties)
│   ├── OptimizeRouteView (optimize → updateRoute)
│   ├── NavigationAppSelectorView (launch nav)
│   └── SideMenuView (new route)
└── Map Layer
    ├── StopAnnotationView (pins)
    └── MapPolyline (route visualization)
```

## Core Services
- **LocationService**: Manages user location permissions and current location
- **GeocodingService**: Converts addresses to coordinates and vice versa
- **NavigationService**: Launches navigation apps with coordinates
- **RouteOptimizationService**: Calculates optimal stop sequences

## Critical Rules — FOLLOW THESE EXACTLY

### 1. File Registration
Every new .swift file MUST be registered in project.pbxproj with:
- PBXBuildFile entry (in Sources section)
- PBXFileReference entry
- Added to the correct PBXGroup (matching folder structure)
- Added to PBXSourcesBuildPhase files list
If you skip this, the file compiles but types are "not found in scope."

### 2. File Creation
NEVER use the create_file tool for Swift files — it causes encoding corruption
(doubled characters like "import SwiftUIimport SwiftUI").
ALWAYS use terminal `cat > filepath << 'ENDOFFILE' ... ENDOFFILE` to create Swift files.

### 3. Before Every Build
- Verify all enum cases match the actual DeliveryStatus definition (.pending, .inProgress, .delivered, .failed, .skipped)
- Verify Stop properties: coordinate (computed), address, notes, status, sequenceNumber
- Verify all referenced views/types exist and are registered in pbxproj
- Run: `xcodebuild clean build -project RouteFlow.xcodeproj -scheme RouteFlow -destination "generic/platform=iOS Simulator" 2>&1 | grep -E "error:|BUILD"`

### 4. Testing
- Build from: /Users/Canpolat/Documents/RouteFlow/RouteFlow/
- Simulator: iPhone 16 Pro Max (E2DF2819-A103-46E9-A044-56874DF4BE07)
- Physical device: Baran's iPhone (needs signing with personal team)
- Always test after changes — don't assume it works

### 5. Git
- Repository root with .git: /Users/Canpolat/Documents/RouteFlow/RouteFlow/
- Always commit from that directory
- Push to origin main

## File Organization Convention
- Views in `Features/{Feature}/Views/`
- ViewModels in `Features/{Feature}/ViewModels/`
- Models in `Core/Models/`
- Services in `Core/Services/`
- Shared components in `Shared/Components/`
- Shared views in `Shared/Views/`
- Extensions in `Core/Utilities/Extensions/`

## Current Features (Working)
1. Route creation with name and date (CreateRouteView)
2. Add stops via address search (SearchStopView fullScreenCover)
3. Stop list in bottom sheet with delete support (StopsBottomSheetView + StopRowInList)
4. Stop detail editing (StopDetailView)
5. Route optimization with polyline visualization (OptimizeRouteView)
6. Navigation to external map apps (NavigationAppSelectorView)
7. Professional logo and animated splash screen (LogoView + LaunchScreenView)
8. Side menu for route management (SideMenuView)
9. Map controls overlay (MapControlsOverlay)

## When Making Changes
1. Read the relevant files FIRST to understand current code
2. Check model definitions before using properties
3. Create files via terminal cat command (NOT create_file tool)
4. Register new files in pbxproj (all 4 sections)
5. Build and verify before committing
6. Test on simulator before pushing

## Known Limitations
- MapPolyline uses static blue color
- Quick-start "copy past stops" feature is placeholder (disabled)
- Single user support (multi-user is future phase)

## Next Steps / Future Phases
1. Phase 6: Past stops quick-add and history
2. Phase 7: Real-time tracking and delivery confirmation
3. Phase 8: Driver analytics and performance metrics
4. Phase 9: Route history and statistics
5. Phase 10: Multi-user and team management

---
**Last Updated**: February 7, 2026
**Repository**: https://github.com/dark1mp/RouteFlow
**Branch**: main
