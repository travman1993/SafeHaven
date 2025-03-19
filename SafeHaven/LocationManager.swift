//
//  LocationsService.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/12/25.
//

//
//  LocationsService.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/12/25.
//
import SwiftUI
import CoreLocation
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var locationError: Error?
    @Published var isLocationAvailable = false

    override init() {
        self.authorizationStatus = .notDetermined
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Check current status
        authorizationStatus = locationManager.authorizationStatus
        
        // If already authorized, start updating
        if locationManager.authorizationStatus == .authorizedWhenInUse ||
           locationManager.authorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }

    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Only publish significant location changes (> 50 meters)
        if let lastLocation = userLocation {
            let lastCLLocation = CLLocation(latitude: lastLocation.latitude, longitude: lastLocation.longitude)
            if lastCLLocation.distance(from: location) < 50 && isLocationAvailable {
                return
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.userLocation = location.coordinate
            self.isLocationAvailable = true
        }
        
        // Notify observers that location updated
        NotificationCenter.default.post(name: NSNotification.Name("LocationDidUpdate"), object: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.locationError = error
            if let error = error as? CLError {
                switch error.code {
                case .denied, .regionMonitoringDenied:
                    // Handle denied access
                    print("Location access denied")
                    // Don't update isLocationAvailable - it should remain as is
                default:
                    // For transient errors, keep the current location status
                    if !self.isLocationAvailable {
                        self.isLocationAvailable = false
                    }
                }
            } else {
                // Generic errors
                if !self.isLocationAvailable {
                    self.isLocationAvailable = false
                }
            }
            print("Location Manager Error: \(error.localizedDescription)")
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.authorizationStatus = manager.authorizationStatus
            
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                manager.startUpdatingLocation()
                
                // If we don't get a location update within 2 seconds, try requestLocation
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    if self?.userLocation == nil {
                        manager.requestLocation()
                    }
                }
                
            case .denied, .restricted:
                // Handle location access denied/restricted
                DispatchQueue.main.async {
                    self.isLocationAvailable = false
                    self.locationError = NSError(
                        domain: "LocationServiceError",
                        code: 1,
                        userInfo: [NSLocalizedDescriptionKey: "Location access denied"]
                    )
                }
                
            case .notDetermined:
                // Wait for user to make a choice
                break
                
            @unknown default:
                break
            }
        }
    }
    
    // Helper function to get user's current location
    func getCurrentLocation() -> CLLocation? {
        guard let coordinate = userLocation else { return nil }
        return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}

// MARK: - Map Content View with Improved Location Handling
struct MapContentView: View {
    let resources: [ResourceLocation]
    let userLocation: CLLocationCoordinate2D?
    @Binding var selectedResource: ResourceLocation?
    @State private var region: MKCoordinateRegion
    @State private var isMapInitialized = false
    
    init(resources: [ResourceLocation], userLocation: CLLocationCoordinate2D?, selectedResource: Binding<ResourceLocation?>) {
        self.resources = resources
        self.userLocation = userLocation
        self._selectedResource = selectedResource
        
        // Initialize with user location if available, otherwise use a default
        if let userLocation = userLocation {
            self._region = State(initialValue: MKCoordinateRegion(
                center: userLocation,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
        } else {
            // Default to San Francisco if no location is available
            self._region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: resources) { resource in
                MapAnnotation(coordinate: resource.coordinate) {
                    ResourceMapPin(resource: resource, onTap: {
                        selectedResource = resource
                    })
                }
            }
            .ignoresSafeArea(edges: .bottom)
            .onAppear {
                updateRegionIfNeeded()
            }
            .onChange(of: userLocation) { newValue in
                updateRegionIfNeeded()
            }
            
            // User location button
            Button(action: {
                if let userLocation = userLocation {
                    withAnimation {
                        region = MKCoordinateRegion(
                            center: userLocation,
                            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                        )
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
    
    private func updateRegionIfNeeded() {
        // Update region with user location if available and not already set
        if let userLocation = userLocation, !isMapInitialized {
            isMapInitialized = true
            region = MKCoordinateRegion(
                center: userLocation,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
        
        // If we have resources but no user location, center on the first resource
        if userLocation == nil && !resources.isEmpty && !isMapInitialized {
            isMapInitialized = true
            let firstResource = resources[0]
            region = MKCoordinateRegion(
                center: firstResource.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
    }
}
