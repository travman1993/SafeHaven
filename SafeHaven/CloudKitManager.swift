//
//  CloudKitManager.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/12/25.
//
import Foundation
import CloudKit

class CloudKitManager: ObservableObject {
    // Singleton instance
    static let shared = CloudKitManager()
    
    private let container: CKContainer
    private let privateDatabase: CKDatabase
    
    @Published var isAvailable = false
    @Published var error: Error?
    
    // Private initializer
    private init() {
        container = CKContainer(identifier: "iCloud.com.yourapp.SafeHaven")
        privateDatabase = container.privateCloudDatabase
        
        checkiCloudAvailability()
    }
    
    private func checkiCloudAvailability() {
        container.accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                switch status {
                case .available:
                    self?.isAvailable = true
                case .noAccount, .restricted, .couldNotDetermine:
                    self?.isAvailable = false
                    self?.error = error
                @unknown default:
                    self?.isAvailable = false
                }
            }
        }
    }
    
    // Save Emergency Contact
    func saveEmergencyContact(_ contact: EmergencyContact, completion: @escaping (Result<EmergencyContact, Error>) -> Void) {
        let record = contact.toCKRecord()
        
        privateDatabase.save(record) { savedRecord, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let savedRecord = savedRecord,
                  let savedContact = EmergencyContact(record: savedRecord) else {
                completion(.failure(NSError(domain: "CloudKitError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to save contact"])))
                return
            }
            
            completion(.success(savedContact))
        }
    }
    
    // Fetch Emergency Contacts
    func fetchEmergencyContacts(completion: @escaping (Result<[EmergencyContact], Error>) -> Void) {
        let query = CKQuery(recordType: "EmergencyContact", predicate: NSPredicate(value: true))
        
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let contacts = records?.compactMap { EmergencyContact(record: $0) } ?? []
            completion(.success(contacts))
        }
    }
    
    // Delete Emergency Contact
    func deleteEmergencyContact(_ contact: EmergencyContact, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let recordID = contact.recordID else {
            completion(.failure(NSError(domain: "CloudKitError", code: -2, userInfo: [NSLocalizedDescriptionKey: "No record ID found"])))
            return
        }
        
        privateDatabase.delete(withRecordID: recordID) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }
}
