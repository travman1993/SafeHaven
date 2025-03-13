import SwiftUI
import CloudKit

struct ContentView: View {
    @StateObject private var cloudKitManager = CloudKitManager.shared
    @State private var emergencyContacts: [EmergencyContact] = []
    
    var body: some View {
        NavigationView {
            List {
                // Emergency Contacts Section
                Section(header: Text("Emergency Contacts")) {
                    ForEach(emergencyContacts) { contact in
                        VStack(alignment: .leading) {
                            Text(contact.name)
                                .font(.headline)
                            Text(contact.phoneNumber)
                                .foregroundColor(.secondary)
                            Text(contact.relationship)
                                .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle("SafeHaven")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Add new contact logic
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                fetchEmergencyContacts()
            }
        }
    }
    
    private func fetchEmergencyContacts() {
        cloudKitManager.fetchEmergencyContacts { result in
            switch result {
            case .success(let contacts):
                DispatchQueue.main.async {
                    self.emergencyContacts = contacts
                }
            case .failure(let error):
                print("Error fetching contacts: \(error.localizedDescription)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
