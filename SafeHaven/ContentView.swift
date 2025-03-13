import SwiftUI
import CloudKit
import CoreLocation

struct ContentView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @EnvironmentObject private var weatherService: WeatherService
    @StateObject private var locationManager = LocationManager()
    
    // State for emergency slider
    @State private var emergencyContacts: [EmergencyContact] = []
    @State private var customMessage = "I need help. This is an emergency. My current location is [Location]. Please contact me or emergency services."
    @State private var showingEmergencyContacts = false
    @State private var showingMotivationView = false

    // State for active tab/section
    @State private var selectedTab: Tab = .home
    
    enum Tab {
        case home, resources, journal, profile
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: - Home Tab
            homeView
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(Tab.home)
            
            // MARK: - Resources Tab
            ResourcesView()
                .tabItem {
                    Label("Resources", systemImage: "mappin.and.ellipse")
                }
                .tag(Tab.resources)
            
            // MARK: - Journal Tab
            JournalView()
                .tabItem {
                    Label("Journal", systemImage: "book.fill")
                }
                .tag(Tab.journal)
            
            // MARK: - Profile Tab
            profileView
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(Tab.profile)
        }
        .accentColor(AppTheme.primary)
        .sheet(isPresented: $showingEmergencyContacts) {
            EmergencyContactsView(contacts: $emergencyContacts, customMessage: $customMessage)
        }
        .sheet(isPresented: $showingMotivationView) {
            MotivationView()
        }
        .onAppear {
            loadEmergencyContacts()
            
            // Request location
            locationManager.requestLocation()
            
            // If location is already available, use it
            updateWeatherIfLocationAvailable()
            
            // Setup notification for when location changes
            NotificationCenter.default.addObserver(forName: NSNotification.Name("LocationDidUpdate"), object: nil, queue: .main) { _ in
                updateWeatherIfLocationAvailable()
            }
        }
    }
    
    private func updateWeatherIfLocationAvailable() {
        if let locationCoordinate = locationManager.userLocation {
            let location = CLLocation(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
            weatherService.fetchWeather(for: location)
        }
    }
    
    // MARK: - Home View
    private var homeView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header with greeting and weather
                headerView
                
                // Emergency Slider
                emergencySliderSection
                
                // Daily Tasks
                dailyTasksSection
                
                // Motivation Card
                motivationCard
                
                // Weather Information
                weatherCard
                
                // Quick Access Sections
                quickAccessGrid
                
                // Space at bottom for comfortable scrolling
                Spacer(minLength: 40)
            }
            .padding()
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("SafeHaven")
        .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome")
                    .font(.headline)
                    .foregroundColor(AppTheme.primary)
                
                Text(getTimeBasedGreeting())
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
            }
            
            Spacer()
            
            // Weather Summary
            if let currentWeather = weatherService.currentWeather {
                VStack(alignment: .trailing) {
                    HStack(spacing: 4) {
                        Text(currentWeather.temperatureString)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Image(systemName: getWeatherIcon(for: currentWeather.condition))
                            .font(.title2)
                    }
                    .foregroundColor(AppTheme.textPrimary)
                    
                    Text(weatherConditionText(for: currentWeather.condition))
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                }
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
    
    // MARK: - Emergency Slider Section
    private var emergencySliderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Emergency")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            EmergencySlider(
                onEmergencyCall: {
                    EmergencyServices.callEmergency()
                }
            )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
    
    // MARK: - Daily Tasks Section
    private var dailyTasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Tasks")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            TodoView()
        }
    }
    
    // MARK: - Motivation Card
    private var motivationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Motivation")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [AppTheme.primary, AppTheme.secondary]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .cornerRadius(12)
                
                // Quote
                Text(getRandomDailyQuote())
                    .font(.system(.body, design: .serif))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding()
                    .multilineTextAlignment(.center)
            }
            .frame(height: 120)
            
            Button(action: {
                showingMotivationView = true
            }) {
                Text("View More Motivational Quotes")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.primary)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.top, 4)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
    
    // MARK: - Weather Card
    private var weatherCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weather & Safety")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            // Check if the weatherService is in a loading state
            Group {
                if weatherService.currentWeather == nil {
                    HStack {
                        ProgressView()
                            .padding(.trailing, 10)
                        Text("Loading weather data...")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .frame(height: 100)
                    .frame(maxWidth: .infinity, alignment: .center)
                } else if let weather = weatherService.currentWeather {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: getWeatherIcon(for: weather.condition))
                                    .font(.title)
                                Text(weather.temperatureString)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            }
                            
                            Text("Feels like \(weather.feelsLikeString)")
                                .font(.subheadline)
                            
                            Text("Humidity: \(weather.humidityString)")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                            
                            Text("Wind: \(weather.windSpeedString)")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        
                        Spacer()
                        
                        // Weather safety tips
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Safety Tips:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text(getWeatherSafetyTip(for: weather.condition))
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
    
    // MARK: - Quick Access Grid
    private var quickAccessGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Access")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                // Resources
                quickAccessButton(
                    title: "Find Resources",
                    icon: "mappin.and.ellipse",
                    color: AppTheme.primary
                ) {
                    selectedTab = .resources
                }
                
                // Journal
                quickAccessButton(
                    title: "Journal",
                    icon: "book.fill",
                    color: AppTheme.secondary
                ) {
                    selectedTab = .journal
                }
                
                // Emergency Contacts
                quickAccessButton(
                    title: "Emergency Contacts",
                    icon: "person.crop.circle.badge.plus",
                    color: AppTheme.accent,
                    action: {
                        showingEmergencyContacts = true
                    }
                )
                
                // Profile/Settings
                quickAccessButton(
                    title: "Profile",
                    icon: "person.fill",
                    color: Color(hex: "F9C74F")
                ) {
                    selectedTab = .profile
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
    
    // MARK: - Profile View
    private var profileView: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile header
                    VStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(AppTheme.primary)
                        
                        Text(authService.fullName?.formatted() ?? "User")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(authService.userEmail ?? "")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding()
                    
                    // Settings sections
                    VStack(spacing: 24) {
                        // Account Settings
                        settingsSection(title: "Account", items: [
                            NavigationSettingsItem(title: "Emergency Contacts", icon: "person.crop.circle.badge.plus", destination: AnyView(EmergencyContactsView(contacts: $emergencyContacts, customMessage: $customMessage))),
                            
                            NavigationSettingsItem(title: "Notification Settings", icon: "bell.badge", destination: AnyView(NotificationSettingsView()))
                        ])
                        
                        // App Settings
                        settingsSection(title: "App Settings", items: [
                            NavigationSettingsItem(title: "App Appearance", icon: "paintbrush", destination: AnyView(AppearanceSettingsView())),
                            
                            NavigationSettingsItem(title: "Privacy Settings", icon: "lock.shield", destination: AnyView(PrivacySettingsView()))
                        ])
                        
                        // About & Support
                        settingsSection(title: "About & Support", items: [
                            NavigationSettingsItem(title: "About SafeHaven", icon: "info.circle", destination: AnyView(AboutSafeHavenView())),
                            
                            NavigationSettingsItem(title: "Developer Story", icon: "person.text.rectangle", destination: AnyView(DeveloperStoryView())),
                            
                            NavigationSettingsItem(title: "Help & Support", icon: "questionmark.circle", destination: AnyView(HelpSupportView()))
                        ])
                        
                        // Sign Out
                        Button(action: {
                            authService.signOut()
                        }) {
                            Text("Sign Out")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.accent)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .padding(.top, 16)
                    }
                    .padding(.bottom, 40)
                }
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Profile")
        }
    }
    
    // MARK: - Helper Views
    // Button content helper (to be used both with Button and NavigationLink)
    private func quickAccessButtonContent(title: String, icon: String, color: Color) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
                .frame(width: 60, height: 60)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(AppTheme.textPrimary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
    
    private func quickAccessButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            quickAccessButtonContent(title: title, icon: icon, color: color)
        }
    }
    
    private func settingsSection(title: String, items: [NavigationSettingsItem]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                ForEach(items.indices, id: \.self) { index in
                    let item = items[index]
                    
                    NavigationLink(destination: item.destination) {
                        HStack {
                            Image(systemName: item.icon)
                                .font(.system(size: 20))
                                .foregroundColor(AppTheme.primary)
                                .frame(width: 24, height: 24)
                            
                            Text(item.title)
                                .font(.body)
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "A0AEC0"))
                        }
                        .padding()
                        .background(Color.white)
                    }
                    
                    if index < items.count - 1 {
                        Divider()
                            .padding(.leading, 56)
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
        }
    }
    
    // MARK: - Helper Methods
    private func loadEmergencyContacts() {
        CloudKitManager.shared.fetchEmergencyContacts { result in
            switch result {
            case .success(let contacts):
                DispatchQueue.main.async {
                    self.emergencyContacts = contacts
                }
            case .failure(let error):
                print("Error fetching emergency contacts: \(error.localizedDescription)")
            }
        }
    }
    
    private func getTimeBasedGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        if hour < 12 {
            return "Good Morning"
        } else if hour < 17 {
            return "Good Afternoon"
        } else {
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

// MARK: - Supporting Struct
struct NavigationSettingsItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let destination: AnyView
}

struct SettingsItem {
    let title: String
    let icon: String
    let action: () -> Void
}

// MARK: - Location Manager Extension
extension LocationManager {
    func requestLocation() {
        let manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
}
