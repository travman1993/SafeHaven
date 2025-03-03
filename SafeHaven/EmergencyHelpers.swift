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
        // We'll return a general location description for safety
        // A real implementation would use the CLLocationManager data
        return "my current location"
    }
    
    static func sendEmergencyTexts(to contacts: [EmergencyContact], withMessage message: String) {
        let locationString = getCurrentLocationString()
        let personalizedMessage = message.replacingOccurrences(of: "[Location]", with: locationString)
        
        // In a real app, you would use MFMessageComposeViewController or a third-party
        // SMS service to send the emergency messages
        
        // This is for demonstration purposes only
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
