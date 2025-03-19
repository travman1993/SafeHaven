//
//  SafeHavenResourceMap.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/19/25.
//
import SwiftUI
import MapKit
import CoreLocation

// Complete replacement for MapContentView with anti-flickering measures
struct SafeHavenResourceMap: View {
    // Input properties
    let resources: [ResourceLocation]
    let userLocation: CLLocationCoordinate2D?
    @Binding var selectedResource: ResourceLocation?
    
    // State
    @State private var cameraPosition: MapCameraPosition
    @State private var isInitialized = false
    @State private var lastCameraUpdate = Date()
    
    init(resources: [ResourceLocation], userLocation: CLLocationCoordinate2D?, selectedResource: Binding<ResourceLocation?>) {
        self.resources = resources
        self.userLocation = userLocation
        self._selectedResource = selectedResource
        
        // Initial camera position
        if let location = userLocation {
            self._cameraPosition = State(initialValue: .region(MKCoordinateRegion(
                center: location,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )))
        } else {
            // Default to San Francisco
            self._cameraPosition = State(initialValue: .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )))
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Modern SwiftUI Map implementation with reduced updates
            Map(position: $cameraPosition) {
                // Resources as annotations
                ForEach(resources) { resource in
                    Annotation(
                        resource.name,
                        coordinate: resource.coordinate,
                        anchor: .bottom
                    ) {
                        // Custom pin view
                        ZStack {
                            Circle()
                                .fill(resource.category.color)
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: resource.category.icon)
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                        }
                        .onTapGesture {
                            selectedResource = resource
                        }
                    }
                }
                
                // Show user location
                if userLocation != nil {
                    UserAnnotation()
                }
            }
            .mapStyle(.standard)
            .mapControls {
                MapCompass()
                MapScaleView()
            }
            .ignoresSafeArea(edges: .bottom)
            .onAppear {
                // Only update once on appear
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if !isInitialized {
                        updateMapIfNeeded()
                    }
                }
            }
            
            // Location button
            Button(action: {
                if let location = userLocation {
                    // Prevent rapid updates
                    let now = Date()
                    if now.timeIntervalSince(lastCameraUpdate) > 0.75 {
                        lastCameraUpdate = now
                        withAnimation(.easeInOut(duration: 0.5)) {
                            cameraPosition = .region(MKCoordinateRegion(
                                center: location,
                                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                            ))
                        }
                    }
                }
            }) {
                Image(systemName: "location.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.blue)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding(20)
            .opacity(userLocation != nil ? 1.0 : 0.5)
            .disabled(userLocation == nil)
        }
    }
    
    private func updateMapIfNeeded() {
        // Don't update if already initialized
        guard !isInitialized else { return }
        
        isInitialized = true
        lastCameraUpdate = Date()
        
        // Use user location if available
        if let location = userLocation {
            withAnimation(.easeInOut(duration: 0.5)) {
                cameraPosition = .region(MKCoordinateRegion(
                    center: location,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                ))
            }
            return
        }
        
        // Otherwise center on first resource if available
        if !resources.isEmpty {
            withAnimation(.easeInOut(duration: 0.5)) {
                cameraPosition = .region(MKCoordinateRegion(
                    center: resources[0].coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                ))
            }
        }
    }
}

// Simple wrapper that forces view recreation when location changes, with debouncing
struct SafeHavenResourceMapContainer: View {
    let resources: [ResourceLocation]
    let userLocation: CLLocationCoordinate2D?
    @Binding var selectedResource: ResourceLocation?
    
    // Track last location update to prevent excessive refreshes
    @State private var lastLocationUpdate = Date()
    @State private var stableLocationId: String = "initial"
    @State private var previousLocation: CLLocationCoordinate2D? = nil
    
    var body: some View {
        SafeHavenResourceMap(
            resources: resources,
            userLocation: userLocation,
            selectedResource: $selectedResource
        )
        .id(stableLocationId)
        // Use onAppear to check if location has changed
        .onAppear {
            checkForLocationChange()
        }
    }
    
    // Manually check if location has changed significantly
    private func checkForLocationChange() {
        // Skip if location hasn't changed significantly or not enough time has passed
        // Handle nil cases properly
        if let current = userLocation, let previous = previousLocation {
            // Both locations exist - check if they're essentially the same
            if abs(current.latitude - previous.latitude) < 0.0001 &&
               abs(current.longitude - previous.longitude) < 0.0001 {
                return
            }
        } else if userLocation == nil && previousLocation == nil {
            // Both are nil - no change
            return
        }
        // Otherwise, locations are different enough to warrant a refresh
        
        let now = Date()
        if now.timeIntervalSince(lastLocationUpdate) > 1.0 {
            lastLocationUpdate = now
            previousLocation = userLocation
            
            // Generate stable ID based on location
            if let location = userLocation {
                // Round coordinates to reduce minor fluctuations
                let roundedLat = (location.latitude * 1000).rounded() / 1000
                let roundedLong = (location.longitude * 1000).rounded() / 1000
                stableLocationId = "\(roundedLat),\(roundedLong)"
            } else {
                stableLocationId = "no-location-\(now.timeIntervalSince1970)"
            }
        }
    }
}
