# Claude Context File for RouteFlow

## Project Overview
RouteFlow is an iOS delivery route management application built with SwiftUI. The app helps users create, manage, and optimize delivery routes with real-time map visualization.

## Key Architecture

### Entry Point
- **App**: `RouteFlowApp.swift` - Initializes LocationService and ModelContainer
- **Main View**: `MainMapView.swift` - Primary map-based interface

### Core Models
- **Route**: Represents a delivery route with multiple stops
  - Properties: id, name, stops (array), isOptimized, totalDistance, estimatedDuration, timestamps
  - Computed: progressPercentage, nextStop, formattedDistance, formattedDuration

- **Stop**: Individual delivery stop
  - Properties: id, address, coordinate, notes, status, sequenceNumber, timestamps
  - Computed: coordinate (CLLocationCoordinate2D), isCompleted
  - Methods: updateStatus()

- **DeliveryStatus**: Enum (Pending, InProgress, Delivered, Failed, Skipped)
  - Each status has: color, icon

- **NavigationApp**: Enum (AppleMaps, GoogleMaps, Waze)
  - Each app has: urlScheme, universalLink, icon

### Core Services
- **LocationService**: Manages user location permissions and current location
- **GeocodingService**: Converts addresses to coordinates and vice versa
- **NavigationService**: Launches navigation apps with coordinates
- **RouteOptimizationService**: Calculates optimal stop sequences

### Features

#### Phase 1: Route Creation
- **CreateRouteView.swift** - Full screen modal for creating new routes
  - Date selection (Today/Tomorrow/Custom)
  - Route name input (optional)
  - Confirm action triggers route creation

#### Phase 2: Stop Detail Management
- **StopDetailView.swift** - View/edit individual stops
  - Mini map showing stop location
  - Editable notes field
  - Status selector with 5 states
  - Remove stop functionality
  - Real-time model updates

#### Phase 2b: Main Map Integration
- **MainMapView.swift** - Primary map interface
  - Full-screen MapKit integration
  - Hamburger menu for navigation
  - Search bar for adding stops
  - Persistent bottom sheet showing stop list
  - Stop pin tapping opens detail view
  - Auto-fit camera to stops

#### Phase 3: Route Optimization
- **OptimizeRouteView.swift** - Route optimization and visualization
  - Blue polyline showing route
  - Statistics display (distance saved, time saved)
  - Optimized stop order list with ETAs
  - Uses RouteOptimizationService
  - Loading state with async operation

#### Phase 4: Navigation App Selection
- **NavigationAppSelectorView.swift** - Choose navigation app
  - Support for 3 navigation apps
  - "Remember choice" toggle with @AppStorage
  - Error handling with alerts
  - Deep linking to maps

#### Phase 5: Error Handling & Animations
- Loading progress indicators
- Empty states with helpful messaging
- Error alerts for failed operations
- Smooth animations:
  - .easeInOut(duration: 0.2) for status changes
  - .asymmetric for list transitions
  - withAnimation() wrappers

### Supporting Components
- **SearchStopView** (in AddStopsView.swift) - Location search interface
- **SideMenuView.swift** - Hamburger menu with "New Route" option
- **StopsBottomSheetView.swift** - Persistent sheet showing route stops
- **MapControlsOverlay.swift** - Map control buttons
- **MapSearchBarView.swift** - Search bar overlay
- **MapWithPinsView.swift** - Shared map component with stops
- **StopAnnotationView.swift** - Styled map pin annotations

### Data Flow

```
MainMapView
├── MainMapViewModel
│   └── AddStopsViewModel (for stop management)
│       ├── LocationService
│       ├── GeocodingService
│       └── ModelContext (SwiftData)
│
├── Sheets/Modals
│   ├── CreateRouteView (onConfirm → createRoute)
│   ├── SearchStopView (select location → addStop)
│   ├── StopDetailView (edit stop properties)
│   ├── OptimizeRouteView (optimize → updateRoute)
│   ├── NavigationAppSelectorView (launch nav)
│   └── SideMenuView (new route)
│
└── Map Layer
    ├── StopAnnotationView (pins)
    └── MapPolyline (route visualization)
```

## Recent Fixes Applied

1. **Xcode Project Registration**
   - Added 5 new view files to project.pbxproj
   - Registered in Sources build phase

2. **File Path Resolution**
   - Corrected file paths from root to subdirectories
   - All files now point to correct RouteFlow/Features/... paths

3. **Deprecated onChange Syntax**
   - Updated AddStopsView to use iOS 17+ syntax
   - Changed from `onChange(of:) { newValue }` to `onChange(of:) { _, newValue }`

4. **Duplicate SearchStopView**
   - Removed duplicate file
   - Kept implementation in AddStopsView.swift

5. **MapPolyline Compilation**
   - Simplified coordinate computation
   - Moved state access outside Map content builder

## Git Commits (Latest 5)
- `0a018d4` - Add comprehensive development summary documentation
- `0ed6393` - Fix OptimizeRouteView compilation errors
- `477e9e6` - Fix duplicate SearchStopView definition
- `9927bb7` - Fix file paths in Xcode project pbxproj
- `9fdf080` - Fix compilation errors: Add files to Xcode project

## Build Information
- **Language**: Swift 5.9+
- **iOS Version**: 16.0+
- **Frameworks**: SwiftUI, SwiftData, MapKit, CoreLocation
- **Xcode**: 15.0+

## Important Notes for Claude
- All SwiftUI views use proper @Environment and @State management
- Models are @Model classes for SwiftData integration
- Navigation uses NavigationStack with sheets and modals
- Async operations use Task and await patterns
- Error handling implemented with do-catch and alerts
- Animations use withAnimation() and modifiers like .transition()

## File Organization Convention
- Views in `Features/{Feature}/Views/`
- ViewModels in `Features/{Feature}/ViewModels/`
- Models in `Core/Models/`
- Services in `Core/Services/`
- Shared components in `Shared/Components/`
- Extensions in `Core/Utilities/Extensions/`

## Known Limitations
- MapPolyline uses static blue color (optimized color toggling moved to future phase)
- Quick-start "copy past stops" feature is placeholder (disabled)
- Single user support (multi-user is future phase)

## Next Steps / Future Phases
1. Phase 6: Past stops quick-add and history
2. Phase 7: Real-time tracking and delivery confirmation
3. Phase 8: Driver analytics and performance metrics
4. Phase 9: Route history and statistics
5. Phase 10: Multi-user and team management

---
**Last Updated**: February 6, 2026  
**Repository**: https://github.com/dark1mp/RouteFlow  
**Branch**: main
