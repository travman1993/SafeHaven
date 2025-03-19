//
//  EmergencyContactsView.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/12/25.
//
import SwiftUI

struct EmergencyContactsView: View {
    @Binding var contacts: [EmergencyContact]
    @Binding var customMessage: String
    @State private var newName = ""
    @State private var newPhone = ""
    @State private var newRelationship = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Emergency Message")) {
                    TextEditor(text: $customMessage)
                        .frame(minHeight: 100)
                        .foregroundColor(.primary)
                        .background(Color(hex: "F5F7FA"))
                        .cornerRadius(8)
                }
                
                Section(header: Text("Your Emergency Contacts")) {
                    if contacts.isEmpty {
                        Text("No contacts added yet")
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        ForEach(contacts) { contact in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(contact.name)
                                    .font(.headline)
                                Text(contact.phoneNumber)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                if !contact.relationship.isEmpty {
                                    Text(contact.relationship)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete(perform: deleteContact)
                    }
                }
                
                Section(header: Text("Add New Contact")) {
                    TextField("Name", text: $newName)
                    TextField("Phone Number", text: $newPhone)
                        .keyboardType(.phonePad)
                    TextField("Relationship (optional)", text: $newRelationship)
                    
                    Button(action: addContact) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Contact")
                                .fontWeight(.medium)
                        }
                        .foregroundColor(Color(hex: "6A89CC"))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 8)
                    }
                    .disabled(newName.isEmpty || newPhone.isEmpty)
                }
                
                Section(footer: Text("These contacts will receive your emergency text message with your location when you use the Emergency SOS feature.")) {
                    // Information about how emergency contacts work
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(Color(hex: "6A89CC"))
                        Text("Emergency contacts will receive a message with your location")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Emergency Contacts")
            .navigationBarItems(trailing: Button("Done") {
                saveContacts()
                dismiss()
            })
        }
    }
    
    private func addContact() {
        if !newName.isEmpty && !newPhone.isEmpty {
            let contact = EmergencyContact(
                name: newName,
                phoneNumber: newPhone,
                relationship: newRelationship.isEmpty ? "Contact" : newRelationship
            )
            contacts.append(contact)
            newName = ""
            newPhone = ""
            newRelationship = ""
            
            saveContacts()
        }
    }
    
    private func deleteContact(at offsets: IndexSet) {
        contacts.remove(atOffsets: offsets)
        saveContacts()
    }
    
    // Save contacts to UserDefaults instead of CloudKit
    private func saveContacts() {
        if let encoded = try? JSONEncoder().encode(contacts) {
            UserDefaults.standard.set(encoded, forKey: "emergencyContacts")
        }
    }
}
