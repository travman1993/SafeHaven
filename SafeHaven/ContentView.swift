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
                    
                    // Weather Information
                    weatherCard(for: geometry)
                    
                    //Weather Forecast section
                    if !weatherService.forecastDates.isEmpty {
                        forecastSection(in: geometry)
                    }
                    
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
            
            // Weather Summary - Updated for new WeatherService
            if let temp = weatherService.currentTemperature {
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(weatherService.temperatureString(temp))
                            .font(.system(size: ResponsiveLayout.fontSize(20), weight: .semibold))
                        
                        Image(systemName: getWeatherIcon(for: weatherService.currentCondition))
                            .font(.system(size: ResponsiveLayout.fontSize(20)))
                    }
                    .foregroundColor(AppTheme.textPrimary)
                    
                    Text(weatherService.currentCondition)
                        .font(.system(size: ResponsiveLayout.fontSize(14)))
                        .foregroundColor(AppTheme.textSecondary)
                    
                    // Apple Weather attribution
                    HStack(spacing: 2) {
                        Image(systemName: "apple.logo")
                            .font(.system(size: ResponsiveLayout.fontSize(8)))
                            .foregroundColor(AppTheme.textSecondary)
                        
                        Text("Weather")
                            .font(.system(size: ResponsiveLayout.fontSize(8)))
                            .foregroundColor(AppTheme.textSecondary)
                        
                        Link("Legal", destination: URL(string: "https://weatherkit.apple.com/legal-attribution.html")!)
                            .font(.system(size: ResponsiveLayout.fontSize(8)))
                            .foregroundColor(AppTheme.primary)
                    }
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
            if let temp = weatherService.currentTemperature {
                VStack(alignment: .leading, spacing: ResponsiveLayout.padding(8)) {
                    HStack {
                        Image(systemName: getWeatherIcon(for: weatherService.currentCondition))
                            .font(.system(size: ResponsiveLayout.fontSize(24)))
                        Text(weatherService.temperatureString(temp))
                            .font(.system(size: ResponsiveLayout.fontSize(22), weight: .semibold))
                    }
                    
                    if let feelsLike = weatherService.currentFeelsLike {
                        Text("Feels like \(weatherService.temperatureString(feelsLike))")
                            .font(.system(size: ResponsiveLayout.fontSize(14)))
                    }
                    
                    Text(getWeatherSafetyTip(for: weatherService.currentCondition))
                        .font(.system(size: ResponsiveLayout.fontSize(12)))
                        .foregroundColor(AppTheme.textSecondary)
                    
                    // Add Apple Weather attribution
                    HStack(spacing: 4) {
                        Image(systemName: "apple.logo")
                            .font(.system(size: ResponsiveLayout.fontSize(10)))
                            .foregroundColor(AppTheme.textSecondary)
                        
                        Text("Weather")
                            .font(.system(size: ResponsiveLayout.fontSize(10)))
                            .foregroundColor(AppTheme.textSecondary)
                        
                        Link("Legal", destination: URL(string: "https://weatherkit.apple.com/legal-attribution.html")!)
                            .font(.system(size: ResponsiveLayout.fontSize(10)))
                            .foregroundColor(AppTheme.primary)
                    }
                    .padding(.top, 4)
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
    
    private func forecastSection(in geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: ResponsiveLayout.padding(12)) {
            Text("5-Day Forecast")
                .font(.system(size: ResponsiveLayout.fontSize(16), weight: .semibold))
                .padding(.horizontal, ResponsiveLayout.padding())
            
            if weatherService.isLoading && weatherService.forecastDates.isEmpty {
                HStack {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.2)
                        .padding()
                    Spacer()
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: ResponsiveLayout.padding(16)) {
                        ForEach(0..<min(5, weatherService.forecastDates.count), id: \.self) { index in
                            VStack(spacing: ResponsiveLayout.padding(8)) {
                                // Use our improved date format function
                                Text(formatDate(weatherService.forecastDates[index]))
                                    .font(.system(size: ResponsiveLayout.fontSize(14), weight: .medium))
                                
                                Image(systemName: getWeatherIcon(for: weatherService.forecastConditions[index]))
                                    .font(.system(size: ResponsiveLayout.fontSize(22)))
                                    .foregroundColor(AppTheme.primary)
                                
                                Text(weatherService.temperatureString(weatherService.forecastHighs[index]))
                                    .font(.system(size: ResponsiveLayout.fontSize(14), weight: .semibold))
                                
                                Text(weatherService.temperatureString(weatherService.forecastLows[index]))
                                    .font(.system(size: ResponsiveLayout.fontSize(12)))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            .padding(ResponsiveLayout.padding())
                            .background(Color.white)
                            .cornerRadius(ResponsiveLayout.isIPad ? 16 : 12)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            .frame(minWidth: 110) // Slightly wider to fit new date format
                        }
                    }
                    .padding(.horizontal, ResponsiveLayout.padding())
                }
            }
            
            // Apple Weather attribution - must include this here too
            HStack(spacing: 4) {
                Image(systemName: "apple.logo")
                    .font(.system(size: ResponsiveLayout.fontSize(10)))
                    .foregroundColor(AppTheme.textSecondary)
                
                Text("Weather")
                    .font(.system(size: ResponsiveLayout.fontSize(10)))
                    .foregroundColor(AppTheme.textSecondary)
                
                Link("Legal", destination: URL(string: "https://weatherkit.apple.com/legal-attribution.html")!)
                    .font(.system(size: ResponsiveLayout.fontSize(10)))
                    .foregroundColor(AppTheme.primary)
            }
            .padding(.horizontal, ResponsiveLayout.padding())
            .padding(.bottom, ResponsiveLayout.padding(8))
            
            // Show loading or error messages if needed
            if weatherService.isLoading {
                HStack {
                    Spacer()
                    Text("Updating weather data...")
                        .font(.system(size: ResponsiveLayout.fontSize(12)))
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(.horizontal)
                    Spacer()
                }
            } else if let error = weatherService.error {
                HStack {
                    Spacer()
                    Text("Tap to retry weather update")
                        .font(.system(size: ResponsiveLayout.fontSize(12)))
                        .foregroundColor(AppTheme.accent)
                        .padding(.horizontal)
                        .onTapGesture {
                            if let location = locationService.currentLocation {
                                weatherService.fetchWeather(for: location)
                            }
                        }
                    Spacer()
                }
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
    
    // MARK: - Helper Methods
    
    // Helper function to format the date
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE • MM/dd"  // Day name with a bullet separator + Month/day format
        return formatter.string(from: date)
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
    
    // Updated to use condition strings instead of enum
    private func getWeatherIcon(for conditionString: String) -> String {
        switch conditionString {
        case "Clear":
            return "sun.max.fill"
        case "Cloudy":
            return "cloud.fill"
        case "Foggy":
            return "cloud.fog.fill"
        case "Hazy":
            return "sun.haze.fill"
        case "Rainy":
            return "cloud.rain.fill"
        case "Snowy":
            return "cloud.snow.fill"
        case "Thunderstorms":
            return "cloud.bolt.fill"
        case "Windy", "Breezy":
            return "wind"
        case "Hot":
            return "thermometer.sun.fill"
        case "Cold":
            return "thermometer.snowflake"
        default:
            return "questionmark.circle"
        }
    }
    
    // Updated to use condition strings instead of enum
    private func getWeatherSafetyTip(for conditionString: String) -> String {
        switch conditionString {
        case "Clear":
            return "Enjoy the good weather, but don't forget sunscreen if you're spending time outdoors."
        case "Hot":
            return "Stay hydrated and seek shade during peak hours. Check on vulnerable people who may need assistance."
        case "Cold":
            return "Dress in layers and cover extremities. Keep emergency supplies in your vehicle if traveling."
        case "Rainy":
            return "Drive carefully on wet roads and watch for flash flooding in low-lying areas."
        case "Thunderstorms":
            return "Stay indoors and away from windows. Avoid using electrical appliances if lightning is nearby."
        case "Snowy":
            return "Travel only if necessary. Keep emergency supplies and warm clothing accessible."
        case "Foggy":
            return "Use low beam headlights when driving and reduce speed. Allow extra distance between vehicles."
        case "Windy", "Breezy":
            return "Secure loose objects outdoors. Be cautious of falling branches and power lines."
        default:
            return "Stay updated on changing weather conditions and have emergency supplies ready."
        }
    }
}
