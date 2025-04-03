import SwiftUI
import CoreLocation
import MapKit


// MARK: - Views
struct ContentView: View {
    // Services and state management
    @StateObject private var locationService = LocationService()
    
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
                    // Header with greeting
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
    
    // Helper Functions
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
