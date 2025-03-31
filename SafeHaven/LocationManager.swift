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
    
    @Published var currentLocation: CLLocation?
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
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
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
            if let location = locations.last {
                print("Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                
                DispatchQueue.main.async { [weak self] in
                    self?.currentLocation = location
                    
                    // Notify observers that location updated
                    NotificationCenter.default.post(name: NSNotification.Name("LocationDidUpdate"), object: nil)
                }
            }
        }
        
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Location error: \(error.localizedDescription)")
            
            DispatchQueue.main.async { [weak self] in
                self?.locationError = error
                
                // Some location errors are expected and can be ignored (like when updates are temporarily unavailable)
                if let clError = error as? CLError {
                    switch clError.code {
                    case .locationUnknown, .network, .denied:
                        // These are more serious errors that we should handle
                        print("Significant location error: \(clError.code)")
                    default:
                        // These can often be ignored as they're temporary
                        print("Minor location error: \(clError.code)")
                        return
                    }
                }
                
                // For significant errors, notify observers
                NotificationCenter.default.post(name: NSNotification.Name("LocationError"), object: error)
            }
        }
        
        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            let status = manager.authorizationStatus
            print("Location authorization changed: \(status.rawValue)")
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.authorizationStatus = status
                
                switch status {
                case .authorizedWhenInUse, .authorizedAlways:
                    print("Location authorization granted, requesting location")
                    manager.requestLocation()
                    manager.startUpdatingLocation()
                    
                case .denied, .restricted:
                    print("Location access denied/restricted")
                    self.locationError = NSError(
                        domain: "LocationServiceError",
                        code: 1,
                        userInfo: [NSLocalizedDescriptionKey: "Location access denied"]
                    )
                    
                    // Notify observers of authorization change
                    NotificationCenter.default.post(name: NSNotification.Name("LocationAuthorizationDenied"), object: nil)
                    
                case .notDetermined:
                    print("Location authorization not determined yet")
                    
                @unknown default:
                    print("Unknown location authorization status")
                }
            }
        }
    
    // Helper function to get user's current location
    func getCurrentLocation() -> CLLocation? {
        guard let coordinate = userLocation else { return nil }
        return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}

