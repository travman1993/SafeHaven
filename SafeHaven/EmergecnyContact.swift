//
//  EmergecnyContact.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/12/25.
//
import Foundation

// Single definition of EmergencyContact to be used throughout the app
struct EmergencyContact: Identifiable, Codable {
    let id: UUID
    var name: String
    var phoneNumber: String
    var relationship: String
    
    init(id: UUID = UUID(), name: String, phoneNumber: String, relationship: String = "Contact") {
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.relationship = relationship
    }
}
