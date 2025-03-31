//
//  LocationService.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/19/25.
//

import Foundation
import CoreLocation
import SwiftUI

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var locationError: Error?
    
    override init() {
        self.authorizationStatus = locationManager.authorizationStatus
        
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // If already authorized, start updating
        if locationManager.authorizationStatus == .authorizedWhenInUse ||
           locationManager.authorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    func requestLocation() {
            print("Location request initiated")
            
            if locationManager.authorizationStatus == .notDetermined {
                print("Requesting location authorization")
                locationManager.requestWhenInUseAuthorization()
            } else if locationManager.authorizationStatus == .authorizedWhenInUse ||
                      locationManager.authorizationStatus == .authorizedAlways {
                print("Authorization already granted, requesting location")
                locationManager.requestLocation()
                
                // Also start continuous updates to ensure we get frequent location data
                locationManager.startUpdatingLocation()
                
                // If we already have a location stored, use it immediately
                if currentLocation != nil {
                    print("Using existing location while waiting for update")
                    NotificationCenter.default.post(name: NSNotification.Name("LocationDidUpdate"), object: nil)
                }
            } else {
                print("Location authorization denied: \(locationManager.authorizationStatus.rawValue)")
                // Handle denied case by notifying observers anyway
                NotificationCenter.default.post(name: NSNotification.Name("LocationAuthorizationDenied"), object: nil)
            }
        }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            DispatchQueue.main.async { [weak self] in
                self?.currentLocation = location
            }
            
            // Notify observers that location updated
            NotificationCenter.default.post(name: NSNotification.Name("LocationDidUpdate"), object: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.locationError = error
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async { [weak self] in
            self?.authorizationStatus = manager.authorizationStatus
            
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                manager.requestLocation()
            default:
                break
            }
        }
    }
    
    // Helper method to format the current address
    func formattedAddress() -> String {
        guard let location = currentLocation else {
            return "Unknown location"
        }
        
        // Use CLGeocoder to get the address, but return a placeholder since geocoding is asynchronous
        return "Lat: \(location.coordinate.latitude), Long: \(location.coordinate.longitude)"
    }
}
