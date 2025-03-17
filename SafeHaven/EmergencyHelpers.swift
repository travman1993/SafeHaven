import Foundation
import SwiftUI
import CloudKit
import WeatherKit
import CoreLocation
import AuthenticationServices

// Extension to handle phone calls
extension UIApplication {
    static func makePhoneCall(to number: String) {
        if let url = URL(string: "tel://\(number)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

// Utility to handle SMS functionality
class EmergencyServices {
    static func callEmergency() {
        // Use dispatch async to ensure UI operations happen on main thread
        DispatchQueue.main.async {
            if let url = URL(string: "tel://911"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    // In EmergencyHelpers.swift
    static func getCurrentLocationString() -> String {
        let locationService = LocationService()
        if let location = locationService.currentLocation {
            return "Latitude: \(location.coordinate.latitude), Longitude: \(location.coordinate.longitude)"
        }
        return "unknown location"
    }
    
    static func sendEmergencyTexts(to contacts: [EmergencyContact], withMessage message: String) {
        let locationString = getCurrentLocationString()
        let personalizedMessage = message.replacingOccurrences(of: "[Location]", with: locationString)
        
        for contact in contacts {
            sendTextMessage(to: contact.phoneNumber, message: personalizedMessage)
        }
    }
    
    static func sendTextMessage(to phoneNumber: String, message: String) {
        // Format the phone number to remove any spaces or special characters
        let formattedNumber = phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        // Create the SMS URL
        if let url = URL(string: "sms:\(formattedNumber)&body=\(message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
            DispatchQueue.main.async {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}

// Permission utility to request and verify location permissions
class LocationPermissionManager: ObservableObject {
    @Published var isAuthorized = false
    
    private let locationManager = CLLocationManager()
    
    init() {
        checkPermission()
    }
    
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
        checkPermission()
    }
    
    private func checkPermission() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            isAuthorized = true
        default:
            isAuthorized = false
        }
    }
}
