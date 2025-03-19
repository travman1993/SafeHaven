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
        GeometryReader { geometry in
            NavigationView {
                Form {
                    // Emergency Message Section
                    Section(header: Text("Emergency Message")) {
                        TextEditor(text: $customMessage)
                            .frame(minHeight: ResponsiveLayout.isIPad ? 150 : 100)
                            .font(.system(
                                size: ResponsiveLayout.fontSize(16)
                            ))
                            .foregroundColor(.primary)
                            .background(Color(hex: "F5F7FA"))
                            .cornerRadius(8)
                    }
                    
                    // Existing Contacts Section
                    Section(header: Text("Your Emergency Contacts")) {
                        if contacts.isEmpty {
                            Text("No contacts added yet")
                                .font(.system(
                                    size: ResponsiveLayout.fontSize(14)
                                ))
                                .foregroundColor(.secondary)
                                .italic()
                        } else {
                            ForEach(contacts) { contact in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(contact.name)
                                        .font(.system(
                                            size: ResponsiveLayout.fontSize(16),
                                            weight: .semibold
                                        ))
                                    
                                    Text(contact.phoneNumber)
                                        .font(.system(
                                            size: ResponsiveLayout.fontSize(14)
                                        ))
                                        .foregroundColor(.gray)
                                    
                                    if !contact.relationship.isEmpty {
                                        Text(contact.relationship)
                                            .font(.system(
                                                size: ResponsiveLayout.fontSize(12)
                                            ))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.vertical, ResponsiveLayout.padding(4))
                            }
                            .onDelete(perform: deleteContact)
                        }
                    }
                    
                    // Add New Contact Section
                    Section(header: Text("Add New Contact")) {
                        TextField("Name", text: $newName)
                            .font(.system(
                                size: ResponsiveLayout.fontSize(16)
                            ))
                        
                        TextField("Phone Number", text: $newPhone)
                            .keyboardType(.phonePad)
                            .font(.system(
                                size: ResponsiveLayout.fontSize(16)
                            ))
                        
                        TextField("Relationship (optional)", text: $newRelationship)
                            .font(.system(
                                size: ResponsiveLayout.fontSize(16)
                            ))
                        
                        Button(action: addContact) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(Color(hex: "6A89CC"))
                                
                                Text("Add Contact")
                                    .fontWeight(.medium)
                                    .font(.system(
                                        size: ResponsiveLayout.fontSize(16)
                                    ))
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, ResponsiveLayout.padding(8))
                        }
                        .disabled(newName.isEmpty || newPhone.isEmpty)
                    }
                    
                    // Footer Section with Information
                    Section(footer:
                        Text("These contacts will receive your emergency text message with your location when you use the Emergency SOS feature.")
                            .font(.system(
                                size: ResponsiveLayout.fontSize(12)
                            ))
                    ) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(Color(hex: "6A89CC"))
                            
                            Text("Emergency contacts will receive a message with your location")
                                .font(.system(
                                    size: ResponsiveLayout.fontSize(14)
                                ))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, ResponsiveLayout.padding(4))
                    }
                }
                .navigationTitle("Emergency Contacts")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: Button("Done") {
                    saveContacts()
                    dismiss()
                })
            }
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
