//
//  EmergencyContactView.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 2/26/25.
//

import SwiftUI

struct EmergencyContactsView: View {
    @Binding var contacts: [EmergencyContact]
    @Binding var customMessage: String
    @State private var newContactName = ""
    @State private var newContactPhone = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Emergency Message")) {
                    TextEditor(text: $customMessage)
                        .frame(height: 100)
                        .foregroundColor(Color(hex: "2D3748"))
                    
                    Text("This message will be sent to your emergency contacts along with your current location.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Section(header: Text("Add New Contact (Max 5)")) {
                    TextField("Name", text: $newContactName)
                    TextField("Phone Number", text: $newContactPhone)
                        .keyboardType(.phonePad)
                    
                    Button(action: addContact) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Contact")
                        }
                    }
                    .disabled(newContactName.isEmpty || newContactPhone.isEmpty || contacts.count >= 5)
                }
                
                Section(header: Text("Your Emergency Contacts")) {
                    if contacts.isEmpty {
                        Text("No emergency contacts added yet")
                            .foregroundColor(.gray)
                            .italic()
                    } else {
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
                                
                                Image(systemName: "person.crop.circle.fill")
                                    .foregroundColor(Color(hex: "6A89CC"))
                            }
                        }
                        .onDelete(perform: deleteContacts)
                    }
                }
                
                Section(footer: Text("You can add up to 5 emergency contacts who will receive your emergency message when you use the emergency slider.")) {
                    // Empty section for footer
                }
            }
            .navigationTitle("Emergency Contacts")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func addContact() {
        guard !newContactName.isEmpty, !newContactPhone.isEmpty, contacts.count < 5 else { return }
        
        contacts.append(EmergencyContact(name: newContactName, phoneNumber: newContactPhone))
        newContactName = ""
        newContactPhone = ""
    }
    
    private func deleteContacts(at offsets: IndexSet) {
        contacts.remove(atOffsets: offsets)
    }
}
