//
//  EmergecnyContact.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/12/25.
//
import Foundation
import CloudKit

struct EmergencyContact: Identifiable {
    let id: UUID
    var name: String
    var phoneNumber: String
    var relationship: String
    var recordID: CKRecord.ID?
    
    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: "EmergencyContact", recordID: self.recordID ?? CKRecord.ID(recordName: id.uuidString))
        record["id"] = id.uuidString
        record["name"] = name
        record["phoneNumber"] = phoneNumber
        record["relationship"] = relationship
        return record
    }
    
    init?(from record: CKRecord) {
        guard let name = record["name"] as? String,
              let phoneNumber = record["phoneNumber"] as? String,
              let idString = record["id"] as? String,
              let id = UUID(uuidString: idString) else {
            return nil
        }
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.relationship = record["relationship"] as? String ?? "Contact"
        self.recordID = record.recordID
    }
    
    init(id: UUID = UUID(), name: String, phoneNumber: String, relationship: String = "Contact", recordID: CKRecord.ID? = nil) {
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.relationship = relationship
        self.recordID = recordID
    }
}
