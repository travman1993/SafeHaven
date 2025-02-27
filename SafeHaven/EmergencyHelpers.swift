import SwiftUI
import UIKit
import CoreLocation

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
        UIApplication.makePhoneCall(to: "911")
    }
    
    static func getCurrentLocationString() -> String {
        // In a real app, you would implement proper location services
        // This is a placeholder
        return "Location services not available"
    }
    
    static func sendEmergencyTexts(to contacts: [EmergencyContact], withMessage message: String) {
        let locationString = getCurrentLocationString()
        let personalizedMessage = message.replacingOccurrences(of: "[Location]", with: locationString)
        
        // In a real app, you would use MFMessageComposeViewController or a third-party
        // SMS service to send the emergency messages
        
        // This is for demonstration purposes only
        for contact in contacts {
            print("Would send '\(personalizedMessage)' to \(contact.name) at \(contact.phoneNumber)")
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
