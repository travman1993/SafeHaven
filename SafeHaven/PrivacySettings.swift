//
//  PrivacySettings.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/13/25.
//
import SwiftUI
import CoreLocation

struct PrivacySettingsView: View {
    @AppStorage("shareLocationForWeather") private var shareLocationForWeather = true
    @AppStorage("shareLocationForResources") private var shareLocationForResources = true
    @AppStorage("shareLocationForEmergencies") private var shareLocationForEmergencies = true
    @AppStorage("analyticsOptIn") private var analyticsOptIn = true
    @State private var showingLocationAlert = false
    @State private var showingDataStorageDetails = false
    
    var body: some View {
        Form {
            Section(header: Text("Location Sharing")) {
                Toggle("Weather Information", isOn: $shareLocationForWeather)
                    .onChange(of: shareLocationForWeather) { _, newValue in
                        if newValue {
                            checkLocationPermission()
                        }
                    }

                Toggle("Find Resources Nearby", isOn: $shareLocationForResources)
                    .onChange(of: shareLocationForResources) { _, newValue in
                        if newValue {
                            checkLocationPermission()
                        }
                    }

                Toggle("Emergency Services", isOn: $shareLocationForEmergencies)
                    .onChange(of: shareLocationForEmergencies) { _, newValue in
                        if newValue {
                            checkLocationPermission()
                        }
                    }
            }
            
            Section(header: Text("Data Usage"), footer: Text("We use anonymized analytics to improve the app and help more people.")) {
                Toggle("Anonymous Usage Analytics", isOn: $analyticsOptIn)
                
                Button(action: {
                    showingDataStorageDetails = true
                }) {
                    Text("Data Storage & Security")
                }
                .sheet(isPresented: $showingDataStorageDetails) {
                    NavigationView {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Your data is stored securely and encrypted. We never sell your data to third parties.")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                
                                Text("Security Measures:")
                                    .font(.headline)
                                    .padding(.top)
                                
                                HStack(spacing: 12) {
                                    Image(systemName: "lock.shield.fill")
                                        .foregroundColor(AppTheme.primary)
                                    Text("End-to-end encryption")
                                }
                                
                                HStack(spacing: 12) {
                                    Image(systemName: "cloud.fill")
                                        .foregroundColor(AppTheme.primary)
                                    Text("Secure cloud storage")
                                }
                                
                                HStack(spacing: 12) {
                                    Image(systemName: "hand.raised.fill")
                                        .foregroundColor(AppTheme.primary)
                                    Text("Strict privacy controls")
                                }
                            }
                            .padding()
                            .navigationTitle("Data Storage & Security")
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarItems(trailing: Button("Done") {
                                showingDataStorageDetails = false
                            })
                        }
                    }
                }
            }
            
            Section(header: Text("Account")) {
                NavigationLink(destination: DeleteAccountView()) {
                    Text("Delete My Account Data")
                        .foregroundColor(.red)
                }
            }
            
            Section(header: Text("Legal")) {
                NavigationLink(destination: PrivacyPolicyView()) {
                    Text("Privacy Policy")
                }
                
                NavigationLink(destination: TermsOfServiceView()) {
                    Text("Terms of Service")
                }
            }
        }
        .navigationTitle("Privacy & Data")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Location Access", isPresented: $showingLocationAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("SafeHaven needs location access to provide weather information, find nearby resources, and assist during emergencies. Please enable location services in your device settings.")
        }
    }
    
    private func checkLocationPermission() {
        let status = CLLocationManager().authorizationStatus
        if status == .denied || status == .restricted {
            showingLocationAlert = true
        }
    }
}

struct DeleteAccountView: View {
    @State private var confirmationText = ""
    @State private var password = ""
    @State private var showingAlert = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Form {
            Section(header: Text("Delete Account"), footer: Text("Deleting your account will permanently remove all your data including emergency contacts, journal entries, and saved resources. This action cannot be undone.")) {
                SecureField("Enter your password", text: $password)
                
                TextField("Type 'DELETE' to confirm", text: $confirmationText)
                
                Button("Delete My Account") {
                    if confirmationText == "DELETE" && !password.isEmpty {
                        showingAlert = true
                    }
                }
                .foregroundColor(.red)
                .disabled(confirmationText != "DELETE" || password.isEmpty)
            }
        }
        .navigationTitle("Delete Account")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Account Deleted", isPresented: $showingAlert) {
            Button("OK", role: .cancel) {
                // In a real app, this would sign out the user
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Your account and all associated data have been permanently deleted.")
        }
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Privacy Policy")
                    .font(.title)
                    .fontWeight(.bold)
                
                Group {
                    Text("Last Updated: March 13, 2025")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Introduction")
                        .font(.headline)
                    
                    Text("This Privacy Policy describes how SafeHaven collects, uses, and discloses your information when you use our mobile application. We respect your privacy and are committed to protecting your personal data.")
                    
                    Text("Information We Collect")
                        .font(.headline)
                    
                    Text("• Personal Information: Name, email address, and contact information provided during account creation.\n• Emergency Contacts: Names and phone numbers you provide for emergency situations.\n• Location Data: With your permission, we collect location data to provide weather information, find nearby resources, and assist during emergencies.\n• Usage Data: Information about how you use the app, including features accessed and time spent.")
                    
                    Text("How We Use Your Information")
                        .font(.headline)
                    
                    Text("• To provide and maintain our Service\n• To notify you about changes to our Service\n• To allow you to participate in interactive features\n• To provide customer support\n• To gather analysis or valuable information to improve our Service\n• To monitor the usage of our Service\n• To detect, prevent and address technical issues")
                    
                    Text("Data Security")
                        .font(.headline)
                    
                    Text("We implement appropriate technical and organizational measures to protect your personal data against unauthorized or unlawful processing, accidental loss, destruction, or damage.")
                }
                
                Group {
                    Text("Data Sharing")
                        .font(.headline)
                    
                    Text("We do not sell your personal information to third parties. We may share your information with:\n• Service providers who perform services on our behalf\n• Emergency services in case of an emergency\n• Legal authorities when required by law")
                    
                    Text("Your Rights")
                        .font(.headline)
                    
                    Text("Depending on your location, you may have rights to:\n• Access your personal data\n• Correct inaccurate data\n• Delete your data\n• Object to processing\n• Data portability\n• Withdraw consent")
                    
                    Text("Contact Us")
                        .font(.headline)
                    
                    Text("If you have any questions about this Privacy Policy, please contact us at:\nsupport@safehaven-app.com")
                }
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Terms of Service")
                    .font(.title)
                    .fontWeight(.bold)
                
                Group {
                    Text("Last Updated: March 13, 2025")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Acceptance of Terms")
                        .font(.headline)
                    
                    Text("By downloading, installing, or using the SafeHaven application, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the application.")
                    
                    Text("Description of Service")
                        .font(.headline)
                    
                    Text("SafeHaven provides a platform to access safety resources, emergency services, and personal wellness tools. The app includes features such as emergency contact management, resource location, weather information, journaling, and motivational content.")
                    
                    Text("User Accounts")
                        .font(.headline)
                    
                    Text("To use certain features of the Service, you may need to create an account. You are responsible for maintaining the confidentiality of your account information and for all activities that occur under your account.")
                    
                    Text("Emergency Services Disclaimer")
                        .font(.headline)
                    
                    Text("While SafeHaven provides features to contact emergency services, it is not a replacement for official emergency services (911/112/999). In case of a serious emergency, always contact official emergency services directly. SafeHaven is not responsible for any delays, failures, or inadequacies of emergency responses.")
                }
                
                Group {
                    Text("Limitation of Liability")
                        .font(.headline)
                    
                    Text("To the maximum extent permitted by law, SafeHaven shall not be liable for any indirect, incidental, special, consequential, or punitive damages, or any loss of profits or revenues, whether incurred directly or indirectly, or any loss of data, use, goodwill, or other intangible losses resulting from your use or inability to use the Service.")
                    
                    Text("Changes to Terms")
                        .font(.headline)
                    
                    Text("We reserve the right to modify these terms at any time. We will provide notice of significant changes. Your continued use of the Service after such modifications constitutes your acceptance of the modified terms.")
                    
                    Text("Governing Law")
                        .font(.headline)
                    
                    Text("These Terms shall be governed by the laws of the United States, without regard to its conflict of law provisions.")
                    
                    Text("Contact Us")
                        .font(.headline)
                    
                    Text("If you have any questions about these Terms, please contact us at:\nsupport@safehaven-app.com")
                }
            }
            .padding()
        }
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
    }
}
