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

