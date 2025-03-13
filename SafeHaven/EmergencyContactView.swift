import Foundation
import SwiftUI
import CloudKit
import WeatherKit
import CoreLocation
import AuthenticationServices

struct EmergencyContact: Identifiable {
    let id: UUID
    var name: String
    var phoneNumber: String
    var relationship: String
    
    // Optional CloudKit record ID for syncing
    var recordID: CKRecord.ID?
}

struct EmergencyContactView: View {
    @State private var contacts: [EmergencyContact] = []
    @State private var showingAddContact = false
    @State private var selectedContact: EmergencyContact?
    @State private var isEditing = false
    
    @EnvironmentObject var cloudKitManager: CloudKitManager
    
    var body: some View {
        NavigationView {
            List {
                ForEach(contacts) { contact in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(contact.name)
                                .font(.headline)
                            Text(contact.phoneNumber)
                                .foregroundColor(.secondary)
                            Text(contact.relationship)
                                .font(.caption)
                        }
                        
                        Spacer()
                        
                        if isEditing {
                            Button(action: {
                                deleteContact(contact)
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if !isEditing {
                            selectedContact = contact
                        }
                    }
                }
            }
            .navigationTitle("Emergency Contacts")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Done" : "Edit") {
                        withAnimation {
                            isEditing.toggle()
                        }
                    }
                    
                    Button(action: {
                        showingAddContact = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddContact) {
                AddEmergencyContactView(contacts: $contacts, cloudKitManager: cloudKitManager)
            }
            .sheet(item: $selectedContact) { contact in
                EditEmergencyContactView(contact: contact, contacts: $contacts, cloudKitManager: cloudKitManager)
            }
            .onAppear {
                fetchContacts()
            }
        }
    }
    
    private func fetchContacts() {
        cloudKitManager.fetchEmergencyContacts { fetchedContacts in
            self.contacts = fetchedContacts.map { contact in
                EmergencyContact(
                    id: UUID(),
                    name: contact.name,
                    phoneNumber: contact.phoneNumber,
                    relationship: contact.relationship,
                    recordID: contact.recordID
                )
            }
        }
    }
    
    private func deleteContact(_ contact: EmergencyContact) {
        // Implement CloudKit delete
        if let recordID = contact.recordID {
            cloudKitManager.deleteRecord(recordID: recordID) { result in
                switch result {
                case .success:
                    contacts.removeAll { $0.id == contact.id }
                case .failure(let error):
                    print("Error deleting contact: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct AddEmergencyContactView: View {
    @Binding var contacts: [EmergencyContact]
    @Environment(\.presentationMode) var presentationMode
    var cloudKitManager: CloudKitManager
    
    @State private var name = ""
    @State private var phoneNumber = ""
    @State private var relationship = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                TextField("Phone Number", text: $phoneNumber)
                    .keyboardType(.phonePad)
                TextField("Relationship", text: $relationship)
            }
            .navigationTitle("Add Contact")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveContact()
                }
                .disabled(name.isEmpty || phoneNumber.isEmpty)
            )
        }
    }
    
    private func saveContact() {
        let newContact = EmergencyContact(
            id: UUID(),
            name: name,
            phoneNumber: phoneNumber,
            relationship: relationship
        )
        
        // Save to CloudKit
        let record = CKRecord(recordType: "EmergencyContact")
        record["name"] = newContact.name
        record["phoneNumber"] = newContact.phoneNumber
        record["relationship"] = newContact.relationship
        
        cloudKitManager.saveRecord(record) { result in
            switch result {
            case .success(let savedRecord):
                DispatchQueue.main.async {
                    var savedContact = newContact
                    savedContact.recordID = savedRecord.recordID
                    contacts.append(savedContact)
                    presentationMode.wrappedValue.dismiss()
                }
            case .failure(let error):
                print("Error saving contact: \(error.localizedDescription)")
            }
        }
    }
}

struct EditEmergencyContactView: View {
    var contact: EmergencyContact
    @Binding var contacts: [EmergencyContact]
    var cloudKitManager: CloudKitManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name: String
    @State private var phoneNumber: String
    @State private var relationship: String
    
    init(contact: EmergencyContact, contacts: Binding<[EmergencyContact]>, cloudKitManager: CloudKitManager) {
            self.contact = contact
            self._contacts = contacts
            self.cloudKitManager = cloudKitManager
            
            // Initialize state with existing contact details
            _name = State(initialValue: contact.name)
            _phoneNumber = State(initialValue: contact.phoneNumber)
            _relationship = State(initialValue: contact.relationship)
        }
        
        var body: some View {
            NavigationView {
                Form {
                    TextField("Name", text: $name)
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                    TextField("Relationship", text: $relationship)
                }
                .navigationTitle("Edit Contact")
                .navigationBarItems(
                    leading: Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    },
                    trailing: Button("Save") {
                        updateContact()
                    }
                    .disabled(name.isEmpty || phoneNumber.isEmpty)
                )
            }
        }
        
        private func updateContact() {
            // Ensure we have a valid CloudKit record ID
            guard let recordID = contact.recordID else {
                print("No record ID found for contact")
                return
            }
            
            // Fetch the existing record to update
            cloudKitManager.fetchRecord(recordID: recordID) { result in
                switch result {
                case .success(let existingRecord):
                    // Update the record
                    existingRecord["name"] = name
                    existingRecord["phoneNumber"] = phoneNumber
                    existingRecord["relationship"] = relationship
                    
                    // Save the updated record
                    cloudKitManager.saveRecord(existingRecord) { saveResult in
                        switch saveResult {
                        case .success(let updatedRecord):
                            DispatchQueue.main.async {
                                // Update local contacts array
                                if let index = contacts.firstIndex(where: { $0.id == contact.id }) {
                                    contacts[index] = EmergencyContact(
                                        id: contact.id,
                                        name: name,
                                        phoneNumber: phoneNumber,
                                        relationship: relationship,
                                        recordID: updatedRecord.recordID
                                    )
                                }
                                presentationMode.wrappedValue.dismiss()
                            }
                        case .failure(let error):
                            print("Error updating contact: \(error.localizedDescription)")
                        }
                    }
                case .failure(let error):
                    print("Error fetching contact record: \(error.localizedDescription)")
                }
            }
        }
    }

    // Extension to make EmergencyContact Identifiable for sheet presentation
    extension EmergencyContact: Identifiable {}
