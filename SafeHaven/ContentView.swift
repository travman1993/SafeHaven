import SwiftUI
import CoreLocation
import MapKit

// MARK: - Models
struct EmergencyContact: Codable, Identifiable {
    var id = UUID()
    var name: String
    var phone: String
    var relation: String
}

// MARK: - Helper Classes
class LocationService: ObservableObject {
    // Implementation details for location service
}

class WeatherService: ObservableObject {
    static let shared = WeatherService()
    @Published var currentTemperature: Double?
    @Published var currentCondition: String = "Unknown"
    // Implementation details
}

// MARK: - Helper Types
struct AppTheme {
    static let primary = Color(hex: "43AA8B")
    static let secondary = Color(hex: "90BE6D")
    static let accent = Color(hex: "F94144")
    static let adaptiveBackground = Color(.systemBackground)
    static let adaptiveCardBackground = Color(.secondarySystemBackground)
    static let adaptiveTextPrimary = Color(.label)
    static let adaptiveTextSecondary = Color(.secondaryLabel)
}

struct ResponsiveLayout {
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static func padding(_ base: CGFloat = 16) -> CGFloat {
        isIPad ? base * 1.5 : base
    }
    
    static func fontSize(_ base: CGFloat) -> CGFloat {
        isIPad ? base * 1.3 : base
    }
    
    static func gridColumns() -> [GridItem] {
        let count = isIPad ? 4 : 2
        return Array(repeating: GridItem(.flexible()), count: count)
    }
}

// Volunteer and Donation Tracker View
struct VolunteerDonationTrackerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    @State private var showingAddVolunteerSheet = false
    @State private var showingAddDonationSheet = false
    
    // Sample user stats
    @State private var totalVolunteerHours = 12
    @State private var totalDonations = 5
    @State private var userLevel = "Bronze Helper"
    @State private var progress: CGFloat = 0.48 // Progress to next level
    
    // Sample activities
    @State private var volunteerActivities: [VolunteerActivity] = []
    @State private var donationActivities: [DonationActivity] = []
    
    struct VolunteerActivity: Identifiable {
        let id = UUID()
        let organization: String
        let hours: Int
        let date: Date
        let verified: Bool
    }
    
    struct DonationActivity: Identifiable {
        let id = UUID()
        let organization: String
        let items: String
        let date: Date
        let verified: Bool
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Stats card
                statsCard
                    .padding()
                
                // Tab selector
                Picker("Activity Type", selection: $selectedTab) {
                    Text("Volunteer Hours").tag(0)
                    Text("Donations").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Tab content
                TabView(selection: $selectedTab) {
                    volunteerTab.tag(0)
                    donationTab.tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: selectedTab)
            }
            .background(AppTheme.adaptiveBackground.ignoresSafeArea())
            .navigationTitle("Activity Tracker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if selectedTab == 0 {
                            showingAddVolunteerSheet = true
                        } else {
                            showingAddDonationSheet = true
                        }
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddVolunteerSheet) {
                AddVolunteerActivityView { organization, hours in
                    let newActivity = VolunteerActivity(
                        organization: organization,
                        hours: hours,
                        date: Date(),
                        verified: false
                    )
                    volunteerActivities.insert(newActivity, at: 0)
                    totalVolunteerHours += hours
                    updateLevel()
                }
            }
            .sheet(isPresented: $showingAddDonationSheet) {
                AddDonationActivityView { organization, items in
                    let newActivity = DonationActivity(
                        organization: organization,
                        items: items,
                        date: Date(),
                        verified: false
                    )
                    donationActivities.insert(newActivity, at: 0)
                    totalDonations += 1
                    updateLevel()
                }
            }
            .onAppear {
                if volunteerActivities.isEmpty {
                    // Load sample data
                    volunteerActivities = [
                        VolunteerActivity(organization: "Local Food Bank", hours: 4, date: Date().addingTimeInterval(-7*24*60*60), verified: true),
                        VolunteerActivity(organization: "Community Garden", hours: 3, date: Date().addingTimeInterval(-14*24*60*60), verified: true),
                        VolunteerActivity(organization: "Animal Shelter", hours: 5, date: Date().addingTimeInterval(-21*24*60*60), verified: true)
                    ]
                    
                    donationActivities = [
                        DonationActivity(organization: "Homeless Shelter", items: "Winter Clothes", date: Date().addingTimeInterval(-3*24*60*60), verified: true),
                        DonationActivity(organization: "Food Bank", items: "Canned Goods", date: Date().addingTimeInterval(-10*24*60*60), verified: true),
                        DonationActivity(organization: "School Drive", items: "School Supplies", date: Date().addingTimeInterval(-17*24*60*60), verified: true),
                        DonationActivity(organization: "Disaster Relief", items: "Hygiene Kits", date: Date().addingTimeInterval(-24*24*60*60), verified: true),
                        DonationActivity(organization: "Clothing Drive", items: "Winter Jackets", date: Date().addingTimeInterval(-30*24*60*60), verified: true)
                    ]
                }
            }
        }
    }
    
    private var volunteerTab: some View {
        ScrollView {
            VStack(spacing: ResponsiveLayout.padding(16)) {
                if volunteerActivities.isEmpty {
                    emptyStateView(
                        image: "clock.fill",
                        title: "No Volunteer Hours",
                        message: "Log your volunteer hours to track your contributions and earn recognition"
                    )
                } else {
                    ForEach(volunteerActivities) { activity in
                        volunteerActivityRow(activity)
                    }
                }
            }
            .padding()
        }
    }
    
    private var donationTab: some View {
        ScrollView {
            VStack(spacing: ResponsiveLayout.padding(16)) {
                if donationActivities.isEmpty {
                    emptyStateView(
                        image: "gift.fill",
                        title: "No Donations",
                        message: "Log the items you've donated to help those in need and track your contributions"
                    )
                } else {
                    ForEach(donationActivities) { activity in
                        donationActivityRow(activity)
                    }
                }
            }
            .padding()
        }
    }
    
    private func volunteerActivityRow(_ activity: VolunteerActivity) -> some View {
        HStack {
            Circle()
                .fill(AppTheme.primary.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "clock.fill")
                        .foregroundColor(AppTheme.primary)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.organization)
                    .font(.system(size: ResponsiveLayout.fontSize(16), weight: .semibold))
                    .foregroundColor(AppTheme.adaptiveTextPrimary)
                
                HStack {
                    Text("\(activity.hours) hours")
                        .font(.system(size: ResponsiveLayout.fontSize(14)))
                        .foregroundColor(AppTheme.adaptiveTextSecondary)
                    
                    Spacer()
                    
                    Text(activity.date, style: .date)
                        .font(.system(size: ResponsiveLayout.fontSize(12)))
                        .foregroundColor(AppTheme.adaptiveTextSecondary)
                }
                
                if activity.verified {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 10))
                        
                        Text("Verified")
                            .font(.system(size: 10))
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(4)
                }
            }
            .padding(.leading, 8)
        }
        .padding()
        .background(AppTheme.adaptiveCardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// Badge View
struct LevelBadgeView: View {
    let level: String
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            badgeColor.opacity(0.2),
                            badgeColor.opacity(0.5)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 70, height: 70)
            
            Image(systemName: "star.fill")
                .font(.system(size: 30))
                .foregroundColor(badgeColor)
        }
    }
    
    private var badgeColor: Color {
        switch level {
        case "Bronze Helper": return Color(hex: "CD7F32")
        case "Silver Helper": return Color(hex: "C0C0C0")
        case "Gold Helper": return Color(hex: "FFD700")
        default: return Color.gray
        }
    }
}

// Add Volunteer Activity View
struct AddVolunteerActivityView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var organization = ""
    @State private var hours = ""
    let onSave: (String, Int) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Volunteer Details")) {
                    TextField("Organization Name", text: $organization)
                    
                    TextField("Hours", text: $hours)
                        .keyboardType(.numberPad)
                }
                
                Section(footer: Text("Your volunteer hours will be pending verification. Organizations can verify your hours if they use the SafeHaven app.")) {
                    Button("Log Hours") {
                        if let hoursInt = Int(hours), hoursInt > 0, !organization.isEmpty {
                            onSave(organization, hoursInt)
                            dismiss()
                        }
                    }
                    .disabled(organization.isEmpty || hours.isEmpty)
                }
            }
            .navigationTitle("Log Volunteer Hours")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Add Donation Activity View
struct AddDonationActivityView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var organization = ""
    @State private var items = ""
    let onSave: (String, String) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Donation Details")) {
                    TextField("Organization Name", text: $organization)
                    
                    TextField("Items Donated", text: $items)
                }
                
                Section(footer: Text("Your donation will be pending verification. Organizations can verify your donation if they use the SafeHaven app.")) {
                    Button("Log Donation") {
                        if !organization.isEmpty && !items.isEmpty {
                            onSave(organization, items)
                            dismiss()
                        }
                    }
                    .disabled(organization.isEmpty || items.isEmpty)
                }
            }
            .navigationTitle("Log Donation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func donationActivityRow(_ activity: DonationActivity) -> some View {
        HStack {
            Circle()
                .fill(Color(hex: "E8505B").opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "gift.fill")
                        .foregroundColor(Color(hex: "E8505B"))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.organization)
                    .font(.system(size: ResponsiveLayout.fontSize(16), weight: .semibold))
                    .foregroundColor(AppTheme.adaptiveTextPrimary)
                
                HStack {
                    Text(activity.items)
                        .font(.system(size: ResponsiveLayout.fontSize(14)))
                        .foregroundColor(AppTheme.adaptiveTextSecondary)
                    
                    Spacer()
                    
                    Text(activity.date, style: .date)
                        .font(.system(size: ResponsiveLayout.fontSize(12)))
                        .foregroundColor(AppTheme.adaptiveTextSecondary)
                }
                
                if activity.verified {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 10))
                        
                        Text("Verified")
                            .font(.system(size: 10))
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(4)
                }
            }
            .padding(.leading, 8)
        }
        .padding()
        .background(AppTheme.adaptiveCardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func emptyStateView(image: String, title: String, message: String) -> some View {
        VStack(spacing: ResponsiveLayout.padding(16)) {
            Image(systemName: image)
                .font(.system(size: ResponsiveLayout.fontSize(48)))
                .foregroundColor(AppTheme.adaptiveTextSecondary.opacity(0.5))
                .padding(.bottom, 8)
            
            Text(title)
                .font(.system(size: ResponsiveLayout.fontSize(18), weight: .semibold))
                .foregroundColor(AppTheme.adaptiveTextPrimary)
            
            Text(message)
                .font(.system(size: ResponsiveLayout.fontSize(14)))
                .foregroundColor(AppTheme.adaptiveTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                if selectedTab == 0 {
                    showingAddVolunteerSheet = true
                } else {
                    showingAddDonationSheet = true
                }
            }) {
                Text(selectedTab == 0 ? "Log Hours" : "Log Donation")
                    .font(.system(size: ResponsiveLayout.fontSize(16), weight: .medium))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(selectedTab == 0 ? AppTheme.primary : Color(hex: "E8505B"))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.top, 8)
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
    
    private func updateLevel() {
        // Simple logic to update level based on hours
        if totalVolunteerHours >= 50 {
            userLevel = "Gold Helper"
            progress = 1.0
        } else if totalVolunteerHours >= 25 {
            userLevel = "Silver Helper"
            progress = (CGFloat(totalVolunteerHours) - 25) / 25
        } else {
            userLevel = "Bronze Helper"
            progress = CGFloat(totalVolunteerHours) / 25
        }
    }
    
    private var statsCard: some View {
        VStack(spacing: ResponsiveLayout.padding(16)) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(userLevel)
                        .font(.system(size: ResponsiveLayout.fontSize(20), weight: .bold))
                        .foregroundColor(AppTheme.adaptiveTextPrimary)
                    
                    HStack(spacing: 12) {
                        VStack(alignment: .leading) {
                            Text("\(totalVolunteerHours)")
                                .font(.system(size: ResponsiveLayout.fontSize(24), weight: .bold))
                                .foregroundColor(AppTheme.primary)
                            
                            Text("Hours")
                                .font(.system(size: ResponsiveLayout.fontSize(14)))
                                .foregroundColor(AppTheme.adaptiveTextSecondary)
                        }
                        
                        Divider()
                            .frame(height: 30)
                        
                        VStack(alignment: .leading) {
                            Text("\(totalDonations)")
                                .font(.system(size: ResponsiveLayout.fontSize(24), weight: .bold))
                                .foregroundColor(Color(hex: "E8505B"))
                            
                            Text("Donations")
                                .font(.system(size: ResponsiveLayout.fontSize(14)))
                                .foregroundColor(AppTheme.adaptiveTextSecondary)
                        }
                    }
                }
                
                Spacer()
                
                LevelBadgeView(level: userLevel)
            }
            
            // Progress to next level
            VStack(alignment: .leading, spacing: 4) {
                Text("Progress to Silver Helper")
                    .font(.system(size: ResponsiveLayout.fontSize(14)))
                    .foregroundColor(AppTheme.adaptiveTextSecondary)
                
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(LinearGradient(gradient: Gradient(colors: [AppTheme.primary, Color(hex: "E8505B")]), startPoint: .leading, endPoint: .trailing))
                        .frame(width: UIScreen.main.bounds.width * 0.85 * progress, height: 8)
                        .cornerRadius(4)
                }
                
                Text("12 more hours to reach next level")
                    .font(.system(size: ResponsiveLayout.fontSize(12)))
                    .foregroundColor(AppTheme.adaptiveTextSecondary)
            }
        }
        .padding()
        .background(AppTheme.adaptiveCardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    struct EmergencyServices {
        static func callEmergency() {
            // Implementation to call emergency services
            print("Calling emergency services")
        }
    }
    
    // MARK: - Views
    struct ContentView: View {
        // Services and state management
        @StateObject private var locationService = LocationService()
        @StateObject private var weatherService = WeatherService.shared
        
        // Emergency and modal state
        @State private var emergencyContacts: [EmergencyContact] = []
        @State private var customMessage = "I need help. This is an emergency. My current location is [Location]. Please contact me or emergency services."
        @State private var showingEmergencyContacts = false
        @State private var showingMotivationView = false
        @State private var showingSupportersView = false
        
        // Navigation state
        @State private var selectedTab: Tab = .home
        
        // Tab enumeration
        enum Tab: Hashable {
            case home, resources, journal, settings
        }
        
        // Motivational quotes
        let motivationalQuotes = [
            "Every day is a new beginning.",
            "Believe you can and you're halfway there.",
            "You are stronger than you think.",
            "Small progress is still progress.",
            "Focus on the good."
        ]
        
        var body: some View {
            NavigationStack {
                TabView(selection: $selectedTab) {
                    homeView
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                        .tag(Tab.home)
                    
                    ResourcesView()
                        .tabItem {
                            Label("Resources", systemImage: "mappin.and.ellipse")
                        }
                        .tag(Tab.resources)
                    
                    JournalView()
                        .tabItem {
                            Label("Journal", systemImage: "book.fill")
                        }
                        .tag(Tab.journal)
                    
                    settingsView
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                        .tag(Tab.settings)
                }
                .accentColor(AppTheme.primary)
            }
            .sheet(isPresented: $showingEmergencyContacts) {
                EmergencyContactsView(contacts: $emergencyContacts, customMessage: $customMessage)
            }
            .sheet(isPresented: $showingMotivationView) {
                MotivationView()
            }
            .sheet(isPresented: $showingSupportersView) {
                SupportersView()
            }
            .onAppear {
                loadEmergencyContacts()
            }
        }
        
        // MARK: - Home View
        private var homeView: some View {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: ResponsiveLayout.padding(20)) {
                        // Header with greeting and weather
                        headerView(for: geometry)
                        
                        // Emergency Slider
                        emergencySliderSection(for: geometry)
                        
                        // Daily Tasks
                        dailyTasksSection(for: geometry)
                        
                        // Motivation Card
                        motivationCard(for: geometry)
                        
                        // New Features Section
                        newFeaturesSection(in: geometry)
                        
                        // Quick Access Sections
                        quickAccessGrid(for: geometry)
                        
                        // Space at bottom for comfortable scrolling
                        Spacer(minLength: ResponsiveLayout.padding(40))
                    }
                    .padding(ResponsiveLayout.padding())
                }
                .background(AppTheme.adaptiveBackground.ignoresSafeArea())
                .navigationTitle("SafeHaven")
                .navigationBarTitleDisplayMode(.large)
            }
        }
        
        // MARK: - Settings View
        private var settingsView: some View {
            SettingsView(showingSupportersView: $showingSupportersView)
        }
        
        // MARK: - Home View Component Helpers
        private func headerView(for geometry: GeometryProxy) -> some View {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome")
                        .font(.system(size: ResponsiveLayout.fontSize(16), weight: .medium))
                        .foregroundColor(AppTheme.primary)
                    
                    Text(getTimeBasedGreeting())
                        .font(.system(size: ResponsiveLayout.fontSize(24), weight: .bold))
                        .foregroundColor(AppTheme.adaptiveTextPrimary)
                }
                
                Spacer()
                
                // Weather Summary - Updated for new WeatherService
                if let temp = weatherService.currentTemperature {
                    VStack(alignment: .trailing, spacing: 2) {
                        HStack(spacing: 4) {
                            Text("\(Int(temp))°")
                                .font(.system(size: ResponsiveLayout.fontSize(20), weight: .bold))
                        }
                        .foregroundColor(AppTheme.adaptiveTextPrimary)
                        
                        Text(weatherService.currentCondition)
                            .font(.system(size: ResponsiveLayout.fontSize(14)))
                            .foregroundColor(AppTheme.adaptiveTextSecondary)
                    }
                } else {
                    ProgressView()
                }
            }
            .padding(ResponsiveLayout.padding())
            .background(AppTheme.adaptiveCardBackground)
            .cornerRadius(ResponsiveLayout.isIPad ? 20 : 16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        }
        
        private func emergencySliderSection(for geometry: GeometryProxy) -> some View {
            EmergencySlider(
                onEmergencyCall: {
                    EmergencyServices.callEmergency()
                },
                sliderWidth: max(geometry.size.width - ResponsiveLayout.padding(40), 0) // Ensure positive width
            )
        }
        
        private func dailyTasksSection(for geometry: GeometryProxy) -> some View {
            TodoView()
        }
        
        private func motivationCard(for geometry: GeometryProxy) -> some View {
            Button(action: { showingMotivationView = true }) {
                HStack {
                    Image(systemName: "quote.bubble.fill")
                        .foregroundColor(AppTheme.primary)
                    Text("Daily Motivation")
                        .foregroundColor(AppTheme.adaptiveTextPrimary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(AppTheme.adaptiveTextSecondary)
                }
                .padding()
                .background(AppTheme.adaptiveCardBackground)
                .cornerRadius(ResponsiveLayout.isIPad ? 20 : 16)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
            }
        }
        
        // MARK: - New Features Section
        private func newFeaturesSection(in geometry: GeometryProxy) -> some View {
            VStack(spacing: ResponsiveLayout.padding(20)) {
                // Digital ID Storage Card
                DigitalIDStorageCard()
                
                // Breathing & Meditation Card
                BreathingMeditationCard()
                
                // Volunteer & Donation Tracker Card
                VolunteerDonationCard()
            }
        }
        
        private func quickAccessGrid(for geometry: GeometryProxy) -> some View {
            LazyVGrid(columns: ResponsiveLayout.gridColumns(), spacing: ResponsiveLayout.padding(16)) {
                quickAccessButton(
                    title: "Find Resources",
                    icon: "mappin.and.ellipse",
                    color: AppTheme.primary
                ) {
                    selectedTab = .resources
                }
                
                quickAccessButton(
                    title: "Journal",
                    icon: "book.fill",
                    color: AppTheme.secondary
                ) {
                    selectedTab = .journal
                }
                
                quickAccessButton(
                    title: "Emergency Contacts",
                    icon: "person.crop.circle.badge.plus",
                    color: AppTheme.accent
                ) {
                    showingEmergencyContacts = true
                }
                
                quickAccessButton(
                    title: "Settings",
                    icon: "gear",
                    color: Color(hex: "F9C74F")
                ) {
                    selectedTab = .settings
                }
            }
        }
        
        private func quickAccessButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
            Button(action: action) {
                VStack(spacing: ResponsiveLayout.padding(12)) {
                    Image(systemName: icon)
                        .font(.system(size: ResponsiveLayout.fontSize(28)))
                        .foregroundColor(color)
                        .frame(width: ResponsiveLayout.isIPad ? 80 : 60, height: ResponsiveLayout.isIPad ? 80 : 60)
                        .background(color.opacity(0.1))
                        .clipShape(Circle())
                    
                    Text(title)
                        .font(.system(size: ResponsiveLayout.fontSize(14)))
                        .foregroundColor(AppTheme.adaptiveTextPrimary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(ResponsiveLayout.padding())
                .background(AppTheme.adaptiveCardBackground)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
            }
        }
        
        private func loadEmergencyContacts() {
            if let data = UserDefaults.standard.data(forKey: "emergencyContacts"),
               let contacts = try? JSONDecoder().decode([EmergencyContact].self, from: data) {
                self.emergencyContacts = contacts
            }
        }
        
        // Weather and Greeting Helpers
        private func getTimeBasedGreeting() -> String {
            let hour = Calendar.current.component(.hour, from: Date())
            
            switch hour {
            case 0..<12:
                return "Good Morning"
            case 12..<17:
                return "Good Afternoon"
            default:
                return "Good Evening"
            }
        }
        
        private func getRandomDailyQuote() -> String {
            // Use the current date to seed the random generator
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let dateComponents = calendar.dateComponents([.day, .month, .year], from: today)
            
            // Create a consistent seed value for the day
            let seed = (dateComponents.day ?? 1) +
            ((dateComponents.month ?? 1) * 31) +
            ((dateComponents.year ?? 2025) * 366)
            
            // Use the seed to deterministically select a quote for the day
            let quoteIndex = seed % motivationalQuotes.count
            return motivationalQuotes[quoteIndex]
        }
    }
    
    // MARK: - Extensions for Color
    extension Color {
        init(hex: String) {
            let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
            var int: UInt64 = 0
            Scanner(string: hex).scanHexInt64(&int)
            let a, r, g, b: UInt64
            switch hex.count {
            case 3: // RGB (12-bit)
                (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
            case 6: // RGB (24-bit)
                (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
            case 8: // ARGB (32-bit)
                (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
            default:
                (a, r, g, b) = (1, 1, 1, 0)
            }
            self.init(
                .sRGB,
                red: Double(r) / 255,
                green: Double(g) / 255,
                blue: Double(b) / 255,
                opacity: Double(a) / 255
            )
        }
    }
    
    // MARK: - Supporting Views
    struct EmergencySlider: View {
        var onEmergencyCall: () -> Void
        var sliderWidth: CGFloat
        
        var body: some View {
            Text("Emergency Slider Placeholder")
                .frame(width: sliderWidth, height: 50)
                .background(AppTheme.accent)
                .foregroundColor(.white)
                .cornerRadius(10)
                .onTapGesture {
                    onEmergencyCall()
                }
        }
    }
    
    struct TodoView: View {
        var body: some View {
            Text("Todo View Placeholder")
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .background(AppTheme.adaptiveCardBackground)
                .cornerRadius(16)
        }
    }
    
    struct ResourcesView: View {
        var body: some View {
            Text("Resources View")
        }
    }
    
    struct JournalView: View {
        var body: some View {
            Text("Journal View")
        }
    }
    
    struct SettingsView: View {
        @Binding var showingSupportersView: Bool
        
        var body: some View {
            Text("Settings View")
        }
    }
    
    struct EmergencyContactsView: View {
        @Binding var contacts: [EmergencyContact]
        @Binding var customMessage: String
        
        var body: some View {
            Text("Emergency Contacts View")
        }
    }
    
    struct MotivationView: View {
        var body: some View {
            Text("Motivation View")
        }
    }
    
    struct SupportersView: View {
        var body: some View {
            Text("Supporters View")
        }
    }
    
    // MARK: - Digital ID Storage Card
    struct DigitalIDStorageCard: View {
        @State private var showingIDGallery = false
        
        var body: some View {
            Button(action: {
                showingIDGallery = true
            }) {
                VStack(alignment: .leading, spacing: ResponsiveLayout.padding(12)) {
                    HStack {
                        Image(systemName: "creditcard.fill")
                            .font(.system(size: ResponsiveLayout.fontSize(24)))
                            .foregroundColor(AppTheme.primary)
                        
                        Text("Digital ID Storage")
                            .font(.system(size: ResponsiveLayout.fontSize(18), weight: .semibold))
                            .foregroundColor(AppTheme.adaptiveTextPrimary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(AppTheme.adaptiveTextSecondary)
                    }
                    
                    Text("Securely store important documents offline")
                        .font(.system(size: ResponsiveLayout.fontSize(14)))
                        .foregroundColor(AppTheme.adaptiveTextSecondary)
                        .padding(.top, 2)
                    
                    HStack(spacing: ResponsiveLayout.padding(12)) {
                        Feature(icon: "camera.fill", text: "Take a photo")
                        Feature(icon: "lock.fill", text: "Store on-device only")
                        Feature(icon: "person.text.rectangle", text: "Label & organize")
                    }
                    .padding(.top, 8)
                }
                .padding(ResponsiveLayout.padding())
                .background(AppTheme.adaptiveCardBackground)
                .cornerRadius(ResponsiveLayout.isIPad ? 20 : 16)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
            }
            .sheet(isPresented: $showingIDGallery) {
                DigitalIDGalleryView()
            }
        }
        
        private struct Feature: View {
            let icon: String
            let text: String
            
            var body: some View {
                HStack(spacing: 4) {
                    Image(systemName: icon)
                        .font(.system(size: ResponsiveLayout.fontSize(12)))
                        .foregroundColor(AppTheme.primary)
                    
                    Text(text)
                        .font(.system(size: ResponsiveLayout.fontSize(12)))
                        .foregroundColor(AppTheme.adaptiveTextSecondary)
                }
            }
        }
    }
    
    // Digital ID Gallery View
    struct DigitalIDGalleryView: View {
        @Environment(\.dismiss) private var dismiss
        @State private var showingCamera = false
        @State private var documents: [StoredDocument] = []
        @State private var newImage: UIImage?
        @State private var showingLabelSheet = false
        
        // Mock data - would be replaced with actual document storage
        struct StoredDocument: Identifiable {
            let id = UUID()
            let name: String
            let type: String
            let image: UIImage?
            let date: Date
        }
        
        var body: some View {
            NavigationView {
                ZStack {
                    AppTheme.adaptiveBackground.ignoresSafeArea()
                    
                    VStack {
                        if documents.isEmpty {
                            emptyStateView
                        } else {
                            documentListView
                        }
                    }
                    .navigationTitle("Digital ID Storage")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Close") {
                                dismiss()
                            }
                        }
                        
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                showingCamera = true
                            }) {
                                Image(systemName: "plus")
                            }
                        }
                    }
                }
            }
            .onAppear {
                // Load example documents for demonstration
                if documents.isEmpty {
                    documents = [
                        StoredDocument(name: "Driver's License", type: "ID", image: nil, date: Date()),
                        StoredDocument(name: "Health Insurance", type: "Insurance", image: nil, date: Date())
                    ]
                }
            }
            .sheet(isPresented: $showingCamera) {
                Text("Camera View Placeholder")
                    .font(.title)
                    .padding()
                // In a real implementation, this would be a camera view or image picker
            }
            .sheet(isPresented: $showingLabelSheet) {
                if newImage != nil {
                    DocumentLabelingView(image: newImage!, onSave: { name, type in
                        let newDoc = StoredDocument(name: name, type: type, image: newImage, date: Date())
                        documents.append(newDoc)
                        newImage = nil
                    })
                }
            }
        }
        
        private var emptyStateView: some View {
            VStack(spacing: ResponsiveLayout.padding(20)) {
                Image(systemName: "creditcard.fill")
                    .font(.system(size: ResponsiveLayout.fontSize(60)))
                    .foregroundColor(AppTheme.primary.opacity(0.5))
                    .padding(.bottom, ResponsiveLayout.padding(20))
                
                Text("No Documents Yet")
                    .font(.system(size: ResponsiveLayout.fontSize(20), weight: .semibold))
                    .foregroundColor(AppTheme.adaptiveTextPrimary)
                
                Text("Add your first document by taking a photo or uploading an image")
                    .font(.system(size: ResponsiveLayout.fontSize(16)))
                    .foregroundColor(AppTheme.adaptiveTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, ResponsiveLayout.padding(20))
                
                Button(action: {
                    showingCamera = true
                }) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("Add Document")
                    }
                    .padding()
                    .background(AppTheme.primary)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.top, ResponsiveLayout.padding(20))
            }
            .padding()
        }
        
        private var documentListView: some View {
            List {
                ForEach(documents) { document in
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(AppTheme.primary.opacity(0.1))
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(AppTheme.primary)
                        }
                        
                        VStack(alignment: .leading) {
                            Text(document.name)
                                .font(.headline)
                                .foregroundColor(AppTheme.adaptiveTextPrimary)
                            
                            HStack {
                                Text(document.type)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(AppTheme.primary.opacity(0.1))
                                    .cornerRadius(4)
                                
                                Spacer()
                                
                                Text(document.date, style: .date)
                                    .font(.caption)
                                    .foregroundColor(AppTheme.adaptiveTextSecondary)
                            }
                        }
                        .padding(.leading, 8)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete { indexSet in
                    documents.remove(atOffsets: indexSet)
                }
            }
        }
    }
    
    // Document Labeling View
    struct DocumentLabelingView: View {
        @Environment(\.dismiss) private var dismiss
        let image: UIImage
        let onSave: (String, String) -> Void
        
        @State private var documentName = ""
        @State private var documentType = "ID"
        
        let documentTypes = ["ID", "Insurance", "Medical", "Financial", "Veteran", "Other"]
        
        var body: some View {
            NavigationView {
                Form {
                    Section(header: Text("Document Image")) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                    }
                    
                    Section(header: Text("Document Details")) {
                        TextField("Document Name", text: $documentName)
                        
                        Picker("Document Type", selection: $documentType) {
                            ForEach(documentTypes, id: \.self) { type in
                                Text(type).tag(type)
                            }
                        }
                    }
                }
                .navigationTitle("Label Document")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            onSave(documentName, documentType)
                            dismiss()
                        }
                        .disabled(documentName.isEmpty)
                    }
                }
            }
        }
    }
    
    // MARK: - Breathing & Meditation Card
    struct BreathingMeditationCard: View {
        @State private var showingBreathingView = false
        
        var body: some View {
            Button(action: {
                showingBreathingView = true
            }) {
                VStack(alignment: .leading, spacing: ResponsiveLayout.padding(12)) {
                    HStack {
                        Image(systemName: "lungs.fill")
                            .font(.system(size: ResponsiveLayout.fontSize(24)))
                            .foregroundColor(AppTheme.secondary)
                        
                        Text("Mental Wellness Tools")
                            .font(.system(size: ResponsiveLayout.fontSize(18), weight: .semibold))
                            .foregroundColor(AppTheme.adaptiveTextPrimary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(AppTheme.adaptiveTextSecondary)
                    }
                    
                    Text("Offer calm and care during difficult moments — fully offline")
                        .font(.system(size: ResponsiveLayout.fontSize(14)))
                        .foregroundColor(AppTheme.adaptiveTextSecondary)
                        .padding(.top, 2)
                    
                    HStack(spacing: ResponsiveLayout.padding(12)) {
                        Feature(icon: "wind", text: "Breathing Exercises")
                        Feature(icon: "brain.head.profile", text: "Guided Meditations")
                        Feature(icon: "note.text", text: "Mood Journal")
                    }
                    .padding(.top, 8)
                }
                .padding(ResponsiveLayout.padding())
                .background(AppTheme.adaptiveCardBackground)
                .cornerRadius(ResponsiveLayout.isIPad ? 20 : 16)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
            }
            .sheet(isPresented: $showingBreathingView) {
                BreathingExerciseView()
            }
        }
        
        private struct Feature: View {
            let icon: String
            let text: String
            
            var body: some View {
                HStack(spacing: 4) {
                    Image(systemName: icon)
                        .font(.system(size: ResponsiveLayout.fontSize(12)))
                        .foregroundColor(AppTheme.secondary)
                    
                    Text(text)
                        .font(.system(size: ResponsiveLayout.fontSize(12)))
                        .foregroundColor(AppTheme.adaptiveTextSecondary)
                }
            }
        }
    }
    
    // Breathing Exercise View
    struct BreathingExerciseView: View {
        @Environment(\.dismiss) private var dismiss
        @State private var selectedExercise = "Calm Down"
        @State private var isBreathingActive = false
        @State private var breathPhase: BreathPhase = .inhale
        @State private var progress: CGFloat = 0
        
        enum BreathPhase {
            case inhale, hold, exhale, rest
        }
        
        let exercises = ["Calm Down", "Fall Asleep", "Ease Anxiety"]
        
        var body: some View {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "43AA8B").opacity(0.6),
                        Color(hex: "90BE6D").opacity(0.4)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: ResponsiveLayout.padding(24)) {
                    // Close button
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: ResponsiveLayout.fontSize(24)))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    if !isBreathingActive {
                        // Exercise selection
                        VStack(spacing: ResponsiveLayout.padding(40)) {
                            Text("Breathing Exercises")
                                .font(.system(size: ResponsiveLayout.fontSize(28), weight: .bold))
                                .foregroundColor(.white)
                            
                            VStack(spacing: ResponsiveLayout.padding(16)) {
                                ForEach(exercises, id: \.self) { exercise in
                                    Button(action: {
                                        selectedExercise = exercise
                                    }) {
                                        HStack {
                                            Text(exercise)
                                                .font(.system(size: ResponsiveLayout.fontSize(18), weight: .medium))
                                                .foregroundColor(.white)
                                            
                                            Spacer()
                                            
                                            if selectedExercise == exercise {
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.white)
                                            }
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white.opacity(selectedExercise == exercise ? 0.3 : 0.1))
                                        )
                                    }
                                }
                            }
                            
                            Button(action: {
                                withAnimation {
                                    isBreathingActive = true
                                    startBreathingExercise()
                                }
                            }) {
                                Text("Begin")
                                    .font(.system(size: ResponsiveLayout.fontSize(18), weight: .bold))
                                    .foregroundColor(Color(hex: "43AA8B"))
                                    .padding(.vertical, ResponsiveLayout.padding(16))
                                    .padding(.horizontal, ResponsiveLayout.padding(40))
                                    .background(
                                        Capsule()
                                            .fill(Color.white)
                                    )
                                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                            }
                        }
                        .padding()
                    } else {
                        // Active breathing exercise
                        VStack(spacing: ResponsiveLayout.padding(30)) {
                            Text(selectedExercise)
                                .font(.system(size: ResponsiveLayout.fontSize(24), weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(breathPhaseInstruction)
                                .font(.system(size: ResponsiveLayout.fontSize(20), weight: .medium))
                                .foregroundColor(.white)
                                .animation(.easeInOut, value: breathPhase)
                            
                            // Breathing circle
                            ZStack {
                                Circle()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 2)
                                    .frame(width: 200, height: 200)
                                
                                Circle()
                                    .scale(breathingScale)
                                    .fill(Color.white.opacity(0.3))
                                    .frame(width: 200, height: 200)
                                    .animation(.easeInOut(duration: breathPhaseDuration), value: breathPhase)
                                
                                Text(breathPhaseCountdown)
                                    .font(.system(size: ResponsiveLayout.fontSize(40), weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Button(action: {
                                withAnimation {
                                    isBreathingActive = false
                                }
                            }) {
                                Text("End Session")
                                    .font(.system(size: ResponsiveLayout.fontSize(16), weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 24)
                                    .background(
                                        Capsule()
                                            .stroke(Color.white, lineWidth: 1)
                                    )
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        
        private var breathPhaseInstruction: String {
            switch breathPhase {
            case .inhale: return "Breathe In"
            case .hold: return "Hold"
            case .exhale: return "Breathe Out"
            case .rest: return "Rest"
            }
        }
        
        private var breathPhaseCountdown: String {
            return "\(Int(ceil(breathPhaseDuration * (1 - progress))))"
        }
        
        private var breathPhaseDuration: Double {
            switch breathPhase {
            case .inhale: return 4.0
            case .hold: return 2.0
            case .exhale: return 6.0
            case .rest: return 2.0
            }
        }
        
        private var breathingScale: CGFloat {
            switch breathPhase {
            case .inhale: return 1.0
            case .hold: return 1.0
            case .exhale: return 0.7
            case .rest: return 0.7
            }
        }
        
        private func startBreathingExercise() {
            progress = 0
            breathPhase = .inhale
            animateBreathPhase()
        }
        
        private func animateBreathPhase() {
            withAnimation(.linear(duration: breathPhaseDuration)) {
                progress = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + breathPhaseDuration) {
                if isBreathingActive {
                    progress = 0
                    
                    switch breathPhase {
                    case .inhale: breathPhase = .hold
                    case .hold: breathPhase = .exhale
                    case .exhale: breathPhase = .rest
                    case .rest: breathPhase = .inhale
                    }
                    
                    animateBreathPhase()
                }
            }
        }
    }
}
