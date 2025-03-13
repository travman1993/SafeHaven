//
//  EmergencyContact.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/12/25.
//
import Foundation
import CloudKit

// Separate file for EmergencyContact model
struct EmergencyContact: Identifiable, Codable {
    let id: UUID
    var name: String
    var phoneNumber: String
    var relationship: String
    var recordID: CKRecord.ID?
    
    // Default initializer
    init(id: UUID = UUID(),
         name: String,
         phoneNumber: String,
         relationship: String,
         recordID: CKRecord.ID? = nil) {
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.relationship = relationship
        self.recordID = recordID
    }
    
    // CloudKit record initializer
    init?(record: CKRecord) {
        guard let name = record["name"] as? String,
              let phoneNumber = record["phoneNumber"] as? String,
              let relationship = record["relationship"] as? String else {
            return nil
        }
        
        self.id = UUID()
        self.name = name
        self.phoneNumber = phoneNumber
        self.relationship = relationship
        self.recordID = record.recordID
    }
    
    // Convert to CKRecord
    func toCKRecord() -> CKRecord {
        let record = recordID != nil ?
            CKRecord(recordID: recordID!) :
            CKRecord(recordType: "EmergencyContact")
        record["name"] = name
        record["phoneNumber"] = phoneNumber
        record["relationship"] = relationship
        return record
    }
}
