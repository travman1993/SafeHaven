import SwiftUI
import CoreLocation

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
    
    var body: some View {
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
                    
                    // Weather Information
                    weatherCard(for: geometry)
                    
                    // Quick Access Sections
                    quickAccessGrid(for: geometry)
                    
                    // Space at bottom for comfortable scrolling
                    Spacer(minLength: ResponsiveLayout.padding(40))
                }
                .padding(ResponsiveLayout.padding())
            }
            .background(AppTheme.background.ignoresSafeArea())
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
                    .foregroundColor(AppTheme.textPrimary)
            }
            
            Spacer()
            
            // Weather Summary
            if let currentWeather = weatherService.currentWeather {
                VStack(alignment: .trailing) {
                    HStack(spacing: 4) {
                        Text(currentWeather.temperatureString)
                            .font(.system(size: ResponsiveLayout.fontSize(20), weight: .semibold))
                        
                        Image(systemName: getWeatherIcon(for: currentWeather.condition))
                            .font(.system(size: ResponsiveLayout.fontSize(20)))
                    }
                    .foregroundColor(AppTheme.textPrimary)
                    
                    Text(weatherConditionText(for: currentWeather.condition))
                        .font(.system(size: ResponsiveLayout.fontSize(14)))
                        .foregroundColor(AppTheme.textSecondary)
                }
            } else {
                ProgressView()
            }
        }
        .padding(ResponsiveLayout.padding())
        .background(Color.white)
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
                    .foregroundColor(AppTheme.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(ResponsiveLayout.isIPad ? 20 : 16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        }
    }
    
    private func weatherCard(for geometry: GeometryProxy) -> some View {
        Group {
            if let weather = weatherService.currentWeather {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: getWeatherIcon(for: weather.condition))
                            .font(.system(size: ResponsiveLayout.fontSize(24)))
                        Text(weather.temperatureString)
                            .font(.system(size: ResponsiveLayout.fontSize(22), weight: .semibold))
                    }
                    
                    Text("Feels like \(weather.feelsLikeString)")
                        .font(.system(size: ResponsiveLayout.fontSize(14)))
                    
                    Text(getWeatherSafetyTip(for: weather.condition))
                        .font(.system(size: ResponsiveLayout.fontSize(12)))
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(ResponsiveLayout.isIPad ? 20 : 16)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
            } else {
                ProgressView()
            }
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
    
    // MARK: - Utility Methods
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
                    .foregroundColor(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(ResponsiveLayout.padding())
            .background(Color.white)
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
    
    private func getWeatherIcon(for condition: WeatherCondition) -> String {
        switch condition {
        case .clear:
            return "sun.max.fill"
        case .cloudy:
            return "cloud.fill"
        case .fog, .mist:
            return "cloud.fog.fill"
        case .haze:
            return "sun.haze.fill"
        case .rain:
            return "cloud.rain.fill"
        case .snow:
            return "cloud.snow.fill"
        case .thunderstorms:
            return "cloud.bolt.fill"
        case .wind, .breezy:
            return "wind"
        case .hot, .heat:
            return "thermometer.sun.fill"
        case .cold, .chilly:
            return "thermometer.snowflake"
        case .sunFlurries:
            return "sun.snow.fill"
        case .sunShowers:
            return "sun.rain.fill"
        case .sleet:
            return "cloud.sleet.fill"
        case .blowingSnow:
            return "wind.snow"
        case .blizzard:
            return "snowflake"
        default:
            return "questionmark.circle"
        }
    }
    
    private func weatherConditionText(for condition: WeatherCondition) -> String {
        switch condition {
        case .clear:
            return "Clear Sky"
        case .cloudy:
            return "Cloudy"
        case .fog, .mist:
            return "Foggy"
        case .haze:
            return "Hazy"
        case .rain:
            return "Rainy"
        case .snow:
            return "Snowy"
        case .thunderstorms:
            return "Thunderstorms"
        case .wind, .breezy:
            return "Windy"
        case .hot, .heat:
            return "Hot"
        case .cold, .chilly:
            return "Cold"
        case .sunFlurries:
            return "Sun & Snow"
        case .sunShowers:
            return "Sun & Rain"
        case .sleet:
            return "Sleet"
        case .blowingSnow:
            return "Blowing Snow"
        case .blizzard:
            return "Blizzard"
        default:
            return "Unknown"
        }
    }
    
    private func getWeatherSafetyTip(for condition: WeatherCondition) -> String {
        switch condition {
        case .clear:
            return "Enjoy the good weather, but don't forget sunscreen if you're spending time outdoors."
        case .hot, .heat:
            return "Stay hydrated and seek shade during peak hours. Check on vulnerable people who may need assistance."
        case .cold, .chilly:
            return "Dress in layers and cover extremities. Keep emergency supplies in your vehicle if traveling."
        case .rain:
            return "Drive carefully on wet roads and watch for flash flooding in low-lying areas."
        case .thunderstorms:
            return "Stay indoors and away from windows. Avoid using electrical appliances if lightning is nearby."
        case .snow, .blowingSnow, .blizzard:
            return "Travel only if necessary. Keep emergency supplies and warm clothing accessible."
        case .fog, .mist:
            return "Use low beam headlights when driving and reduce speed. Allow extra distance between vehicles."
        case .wind, .breezy:
            return "Secure loose objects outdoors. Be cautious of falling branches and power lines."
        default:
            return "Stay updated on changing weather conditions and have emergency supplies ready."
        }
    }
}
