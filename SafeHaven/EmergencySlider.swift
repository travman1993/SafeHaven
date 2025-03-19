import SwiftUI
import MessageUI

struct EmergencySlider: View {
    @State private var sliderOffset: CGFloat = 0
    @State private var isDragging = false
    @State private var showingContactsSheet = false
    @State private var showingEmergencyAlert = false
    @State private var emergencyContacts: [EmergencyContact] = []
    @State private var customMessage = "I need help. This is an emergency. My current location is [Location]. Please contact me or emergency services."
    
    let onEmergencyCall: () -> Void
    
    // Dynamically calculated dimensions
    private var sliderWidth: CGFloat
    private var sliderHeight: CGFloat
    private var thumbSize: CGFloat
    
    init(
        onEmergencyCall: @escaping () -> Void,
        sliderWidth: CGFloat
    ) {
        self.onEmergencyCall = onEmergencyCall
        self.sliderWidth = sliderWidth
        
        // Responsive sizing based on device type
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        self.sliderHeight = isIPad ? 80 : 64
        self.thumbSize = isIPad ? 80 : 64
    }
    
    var body: some View {
        VStack(spacing: ResponsiveLayout.padding(16)) {
            // Emergency slider
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: sliderHeight / 2)
                    .fill(Color(hex: "E8505B").opacity(0.2))
                    .frame(width: sliderWidth, height: sliderHeight)
                    .overlay(
                        HStack {
                            Spacer()
                            Text("Slide to Call 911")
                                .font(.system(
                                    size: ResponsiveLayout.fontSize(18),
                                    weight: .bold,
                                    design: .rounded
                                ))
                                .foregroundColor(Color(hex: "E8505B"))
                                .padding(.trailing, thumbSize)
                            Spacer()
                        }
                    )
                
                // Draggable thumb
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "E8505B"), Color(hex: "F47C7C")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: thumbSize, height: thumbSize)
                    .overlay(
                        Image(systemName: "phone.fill")
                            .font(.system(size: ResponsiveLayout.fontSize(24)))
                            .foregroundColor(.white)
                    )
                    .shadow(color: Color(hex: "E8505B").opacity(0.5), radius: 8, x: 0, y: 4)
                    .offset(x: sliderOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                isDragging = true
                                let newOffset = value.translation.width
                                sliderOffset = min(max(0, newOffset), sliderWidth - thumbSize)
                            }
                            .onEnded { value in
                                isDragging = false
                                
                                // If slider dragged more than 80% of the way, trigger emergency call
                                if sliderOffset > (sliderWidth - thumbSize) * 0.8 {
                                    withAnimation {
                                        sliderOffset = sliderWidth - thumbSize
                                    }
                                    // Trigger emergency actions
                                    triggerEmergency()
                                } else {
                                    // Reset slider position
                                    withAnimation {
                                        sliderOffset = 0
                                    }
                                }
                            }
                    )
            }
            
            // Manage emergency contacts button
            Button(action: {
                showingContactsSheet = true
            }) {
                HStack {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: ResponsiveLayout.fontSize(16)))
                    Text("Manage Emergency Contacts")
                        .font(.system(
                            size: ResponsiveLayout.fontSize(14),
                            weight: .medium
                        ))
                }
                .foregroundColor(Color(hex: "E8505B"))
                .padding(.vertical, ResponsiveLayout.padding(6))
            }
        }
        .sheet(isPresented: $showingContactsSheet) {
            EmergencyContactsView(contacts: $emergencyContacts, customMessage: $customMessage)
        }
        .alert(isPresented: $showingEmergencyAlert) {
            Alert(
                title: Text("Emergency Call Initiated"),
                message: Text("Calling 911 and sending emergency text messages to your \(emergencyContacts.count) emergency contacts."),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            // Load contacts from UserDefaults
            loadEmergencyContacts()
        }
    }
    
    private func loadEmergencyContacts() {
        if let data = UserDefaults.standard.data(forKey: "emergencyContacts"),
           let contacts = try? JSONDecoder().decode([EmergencyContact].self, from: data) {
            self.emergencyContacts = contacts
        }
    }
    
    private func triggerEmergency() {
        // Show confirmation alert
        showingEmergencyAlert = true
        
        // This will initiate a call to emergency services
        // Use a slight delay to allow the alert to appear first
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.onEmergencyCall()
        }
        
        // Send text messages to emergency contacts
        if !emergencyContacts.isEmpty {
            sendEmergencyTexts()
        }
        
        // Provide haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Reset slider after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                sliderOffset = 0
            }
        }
    }
    
    private func sendEmergencyTexts() {
        // Get current location
        let locationString = EmergencyServices.getCurrentLocationString()
        
        // Replace placeholder in message
        let personalizedMessage = customMessage.replacingOccurrences(of: "[Location]", with: locationString)
        
        // Send to each contact
        for contact in emergencyContacts {
            EmergencyServices.sendTextMessage(to: contact.phoneNumber, message: personalizedMessage)
        }
    }
}
