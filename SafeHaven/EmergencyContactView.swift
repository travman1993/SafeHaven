//
//  EmergencyContactsView.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/12/25.
//

import SwiftUI
import CloudKit

struct EmergencyContactsView: View {
    @Binding var contacts: [EmergencyContact]
    @Binding var customMessage: String
    @State private var newName = ""
    @State private var newPhone = ""
    @State private var newRelationship = ""
    @Environment(\.dismiss) var dismiss
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showingSubscriptionAlert = false
    
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
                    .disabled(newName.isEmpty || newPhone.isEmpty || !canAddMoreContacts())
                }
                
                if !subscriptionManager.isSubscribed && contacts.count >= subscriptionManager.maxEmergencyContactsFree {
                    Section {
                        Button(action: {
                            showPaywall()
                        }) {
                            HStack {
                                Image(systemName: "star.fill")
                                Text("Upgrade to add more contacts")
                            }
                            .foregroundColor(AppTheme.primary)
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
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
                dismiss()
            })
            .alert("Subscription Required", isPresented: $showingSubscriptionAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Subscribe") {
                    showPaywall()
                }
            } message: {
                Text("Upgrade to SafeHaven Premium to add more than \(subscriptionManager.maxEmergencyContactsFree) emergency contact.")
            }
        }
    }
    
    private func canAddMoreContacts() -> Bool {
        if subscriptionManager.isSubscribed {
            return true
        }
        return contacts.count < subscriptionManager.maxEmergencyContactsFree
    }
    
    private func addContact() {
        if !canAddMoreContacts() {
            showingSubscriptionAlert = true
            return
        }
        
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
        
        // Optional: update CloudKit or local storage
        saveContacts()
    }
    
    // Optional: Save contacts to CloudKit or local storage
    private func saveContacts() {
        // If you want to persist these contacts, you could implement
        // similar CloudKit logic as in your EmergencyContactView
        // or use another storage mechanism that works with your app's architecture
    }
    
    private func showPaywall() {
        // Dismiss current view
        dismiss()
        
        // Use NotificationCenter to show Paywall
        NotificationCenter.default.post(name: Notification.Name("ShowPaywall"), object: nil)
    }
}

// Preview
struct EmergencyContactsView_Previews: PreviewProvider {
    @State static var previewContacts: [EmergencyContact] = [
        EmergencyContact(name: "John Doe", phoneNumber: "555-123-4567", relationship: "Family"),
        EmergencyContact(name: "Jane Smith", phoneNumber: "555-987-6543", relationship: "Friend")
    ]
    
    @State static var previewMessage = "I need help. This is an emergency. My current location is [Location]. Please contact me or emergency services."
    
    static var previews: some View {
        EmergencyContactsView(
            contacts: $previewContacts,
            customMessage: $previewMessage
        )
    }
}
