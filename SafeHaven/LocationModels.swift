//
//  LocationModels.swift
//  SafeHaven
//
//  Created on 4/4/25.
//

import Foundation
import CoreLocation

// Shared location model used across the app
struct DefaultLocation: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let location: CLLocation
    
    static func == (lhs: DefaultLocation, rhs: DefaultLocation) -> Bool {
        return lhs.name == rhs.name
    }
}
