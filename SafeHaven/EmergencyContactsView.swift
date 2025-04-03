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
                // Emergency Message Section
                Section(header: Text("Emergency Message")
                    .foregroundColor(AppTheme.adaptiveTextPrimary)) {
                    TextEditor(text: $customMessage)
                        .frame(minHeight: ResponsiveLayout.isIPad ? 150 : 100)
                        .font(.system(size: ResponsiveLayout.fontSize(16)))
                        .foregroundColor(AppTheme.adaptiveTextPrimary)
                }
                
                // Existing Contacts Section
                Section(header: Text("Your Emergency Contacts")
                    .foregroundColor(AppTheme.adaptiveTextPrimary)) {
                    if contacts.isEmpty {
                        Text("No contacts added yet")
                            .font(.system(size: ResponsiveLayout.fontSize(14)))
                            .foregroundColor(AppTheme.adaptiveTextSecondary)
                            .italic()
                    } else {
                        ForEach(contacts) { contact in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(contact.name)
                                    .font(.system(size: ResponsiveLayout.fontSize(16), weight: .semibold))
                                    .foregroundColor(AppTheme.adaptiveTextPrimary)
                                
                                Text(contact.phoneNumber)
                                    .font(.system(size: ResponsiveLayout.fontSize(14)))
                                    .foregroundColor(AppTheme.adaptiveTextSecondary)
                                
                                if !contact.relationship.isEmpty {
                                    Text(contact.relationship)
                                        .font(.system(size: ResponsiveLayout.fontSize(12)))
                                        .foregroundColor(AppTheme.adaptiveTextSecondary)
                                }
                            }
                        }
                        .onDelete(perform: deleteContact)
                    }
                }
                
                // Add New Contact Section
                Section(header: Text("Add New Contact")
                    .foregroundColor(AppTheme.adaptiveTextPrimary)) {
                    TextField("Name", text: $newName)
                        .font(.system(size: ResponsiveLayout.fontSize(16)))
                        .foregroundColor(AppTheme.adaptiveTextPrimary)
                    
                    TextField("Phone Number", text: $newPhone)
                        .keyboardType(.phonePad)
                        .font(.system(size: ResponsiveLayout.fontSize(16)))
                        .foregroundColor(AppTheme.adaptiveTextPrimary)
                    
                    TextField("Relationship (optional)", text: $newRelationship)
                        .font(.system(size: ResponsiveLayout.fontSize(16)))
                        .foregroundColor(AppTheme.adaptiveTextPrimary)
                    
                    Button(action: addContact) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(AppTheme.primary)
                            
                            Text("Add Contact")
                                .fontWeight(.medium)
                                .foregroundColor(AppTheme.adaptiveTextPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 8)
                    }
                    .disabled(newName.isEmpty || newPhone.isEmpty)
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
    
    private func saveContacts() {
        if let encoded = try? JSONEncoder().encode(contacts) {
            UserDefaults.standard.set(encoded, forKey: "emergencyContacts")
        }
    }
}
