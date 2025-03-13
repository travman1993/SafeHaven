//
//  LocationsService.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/12/25.
//

import Foundation
import CloudKit
import CoreLocation
import MapKit

class LocationService: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    
    @Published var currentLocation: CLLocation?
    @Published var currentPlacemark: CLPlacemark?
    @Published var authorizationStatus: CLAuthorizationStatus?
    @Published var locationError: Error?
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func startContinuousLocationUpdates() {
        locationManager.startUpdatingLocation()
    }
    
    func stopContinuousLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }
    
    // Reverse Geocoding
    func reverseGeocodeLocation(_ location: CLLocation) {
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let error = error {
                self?.locationError = error
                return
            }
            
            self?.currentPlacemark = placemarks?.first
        }
    }
    
    // Get Formatted Address
    func formattedAddress() -> String {
        guard let placemark = currentPlacemark else { return "Unknown Location" }
        
        var addressString = ""
        
        if let streetNumber = placemark.subThoroughfare {
            addressString += streetNumber + " "
        }
        
        if let streetName = placemark.thoroughfare {
            addressString += streetName + ", "
        }
        
        if let city = placemark.locality {
            addressString += city + ", "
        }
        
        if let state = placemark.administrativeArea {
            addressString += state + " "
        }
        
        if let zipCode = placemark.postalCode {
            addressString += zipCode
        }
        
        return addressString
    }
    
    // Calculate Distance Between Two Locations
    func calculateDistance(from startLocation: CLLocation, to endLocation: CLLocation) -> CLLocationDistance {
        return startLocation.distance(from: endLocation)
    }
    
    // Generate MapKit Region
    func generateMapRegion() -> MKCoordinateRegion? {
        guard let location = currentLocation else { return nil }
        
        return MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        currentLocation = location
        reverseGeocodeLocation(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationError = error
        print("Location Manager Error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            // Handle location access denied
            locationError = NSError(domain: "LocationServiceError",
                                    code: 1,
                                    userInfo: [NSLocalizedDescriptionKey: "Location access denied"])
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
}
