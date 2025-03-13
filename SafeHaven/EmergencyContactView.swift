//
//  EmergencyContactView.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/12/25.
//

import SwiftUI
import CloudKit

struct EmergencyContact: Identifiable, Codable {
    let id: UUID
    var name: String
    var phoneNumber: String
    var recordID: CKRecord.ID? // ✅ Must be Optional
}


    // ✅ Add `toCKRecord` function for CloudKit
func toCKRecord() -> CKRecord {
    let record = CKRecord(recordType: "EmergencyContact", recordID: self.recordID ?? CKRecord.ID(recordName: id.uuidString))
    record["id"] = id.uuidString
    record["name"] = name
    record["phoneNumber"] = phoneNumber
    return record
}


    // ✅ Add `init(from:)` for CloudKit
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
    }
}

// MARK: - Emergency Contact View
struct EmergencyContactView: View {
    @State private var contacts: [EmergencyContact] = []
    @State private var showingAddContact = false
    @State private var newContactName = ""
    @State private var newContactPhone = ""

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(contacts) { contact in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(contact.name)
                                    .font(.headline)
                                Text(contact.phoneNumber)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button(action: {
                                callEmergencyContact(contact.phoneNumber)
                            }) {
                                Image(systemName: "phone.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .onDelete(perform: deleteContact)
                }
                .listStyle(InsetGroupedListStyle())

                Button(action: { showingAddContact = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                        Text("Add Contact")
                            .font(.headline)
                    }
                    .foregroundColor(.blue)
                    .padding()
                }
            }
            .navigationTitle("Emergency Contacts")
            .sheet(isPresented: $showingAddContact) {
                addContactSheet
            }
        }
    }

    // MARK: - Add Contact Sheet
    private var addContactSheet: some View {
        NavigationView {
            Form {
                Section(header: Text("Contact Details")) {
                    TextField("Name", text: $newContactName)
                    TextField("Phone Number", text: $newContactPhone)
                        .keyboardType(.phonePad)
                }
                Section {
                    Button("Save Contact") {
                        addNewContact()
                    }
                    .disabled(newContactName.isEmpty || newContactPhone.isEmpty)
                }
            }
            .navigationTitle("Add Contact")
            .navigationBarItems(leading: Button("Cancel") {
                showingAddContact = false
            })
        }
    }

    // MARK: - Contact Actions
    private func addNewContact() {
        let newContact = EmergencyContact(id: UUID(), name: newContactName, phoneNumber: newContactPhone)
        contacts.append(newContact)
        saveContacts()
        newContactName = ""
        newContactPhone = ""
        showingAddContact = false
    }

    private func deleteContact(at offsets: IndexSet) {
        contacts.remove(atOffsets: offsets)
        saveContacts()
    }

    private func callEmergencyContact(_ phoneNumber: String) {
        if let url = URL(string: "tel://\(phoneNumber)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    // MARK: - CloudKit Integration
    private func saveContacts() {
        let database = CKContainer.default().privateCloudDatabase
        for contact in contacts {
            let record = contact.toRecord()
            database.save(record) { _, error in
                if let error = error {
                    print("Error saving contact: \(error.localizedDescription)")
                }
            }
        }
    }

    private func loadContacts() {
        let database = CKContainer.default().privateCloudDatabase
        let query = CKQuery(recordType: "EmergencyContact", predicate: NSPredicate(value: true))

        database.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                print("Error fetching contacts: \(error.localizedDescription)")
                return
            }
            if let records = records {
                DispatchQueue.main.async {
                    contacts = records.compactMap { EmergencyContact(from: $0) }
                }
            }
        }
    }
}

// MARK: - Preview
struct EmergencyContactView_Previews: PreviewProvider {
    static var previews: some View {
        EmergencyContactView()
    }
}
