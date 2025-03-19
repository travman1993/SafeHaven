import SwiftUI
import CoreLocation

struct ContentView: View {
    @EnvironmentObject private var weatherService: WeatherService
    @StateObject private var locationService = LocationService()
    
    // State for emergency slider
    @State private var emergencyContacts: [EmergencyContact] = []
    @State private var customMessage = "I need help. This is an emergency. My current location is [Location]. Please contact me or emergency services."
    @State private var showingEmergencyContacts = false
    @State private var showingMotivationView = false
    @State private var showingSupportersView = false

    // State for active tab/section
    @State private var selectedTab: Tab = .home
    
    enum Tab {
        case home, resources, journal, settings
    }
    
    var body: some View {
        GeometryReader { geometry in
            TabView(selection: $selectedTab) {
                // MARK: - Home Tab
                homeView(for: geometry)
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
                
                // MARK: - Settings Tab (formerly Profile)
                SettingsView(showingSupportersView: $showingSupportersView)
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
                
                // Request location
                locationService.requestLocation()
                
                // If location is already available, use it
                updateWeatherIfLocationAvailable()
                
                // Setup notification for when location changes
                NotificationCenter.default.addObserver(forName: NSNotification.Name("LocationDidUpdate"), object: nil, queue: .main) { _ in
                    updateWeatherIfLocationAvailable()
                }
            }
        }
    }
    
    private func updateWeatherIfLocationAvailable() {
        guard let location = locationService.currentLocation else {
            print("Location not available for weather update")
            return
        }
        
        print("Updating weather with location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        weatherService.fetchWeather(for: location)
    }
    
    // MARK: - Home View with Responsive Design
    private func homeView(for geometry: GeometryProxy) -> some View {
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
    
    // MARK: - Responsive Header View
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
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
        .padding(ResponsiveLayout.padding())
        .background(Color.white)
        .cornerRadius(ResponsiveLayout.isIPad ? 20 : 16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
    
    // MARK: - Responsive Emergency Slider Section
    private func emergencySliderSection(for geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: ResponsiveLayout.padding(12)) {
            Text("Emergency")
                .font(.system(size: ResponsiveLayout.fontSize(18), weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
            
            EmergencySlider(
                onEmergencyCall: {
                    EmergencyServices.callEmergency()
                },
                sliderWidth: geometry.size.width - ResponsiveLayout.padding(40)
            )
        }
        .padding(ResponsiveLayout.padding())
        .background(Color.white)
        .cornerRadius(ResponsiveLayout.isIPad ? 20 : 16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
    
    // MARK: - Daily Tasks Section
    private func dailyTasksSection(for geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: ResponsiveLayout.padding(12)) {
            Text("Daily Tasks")
                .font(.system(size: ResponsiveLayout.fontSize(18), weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
            
            TodoView()
        }
        .padding(ResponsiveLayout.padding())
        .background(Color.white)
        .cornerRadius(ResponsiveLayout.isIPad ? 20 : 16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
    
    // MARK: - Motivation Card
    private func motivationCard(for geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: ResponsiveLayout.padding(12)) {
            Text("Daily Motivation")
                .font(.system(size: ResponsiveLayout.fontSize(18), weight: .semibold))
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
                    .font(.system(size: ResponsiveLayout.fontSize(16), design: .serif))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding()
                    .multilineTextAlignment(.center)
            }
            .frame(height: ResponsiveLayout.isIPad ? 180 : 120)
            
            Button(action: {
                showingMotivationView = true
            }) {
                Text("View More Motivational Quotes")
                    .font(.system(size: ResponsiveLayout.fontSize(14)))
                    .foregroundColor(AppTheme.primary)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.top, 4)
        }
        .padding(ResponsiveLayout.padding())
        .background(Color.white)
        .cornerRadius(ResponsiveLayout.isIPad ? 20 : 16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
    
    // MARK: - Weather Card
    private func weatherCard(for geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: ResponsiveLayout.padding(12)) {
            Text("Weather & Safety")
                .font(.system(size: ResponsiveLayout.fontSize(18), weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
            
            // Check if the weatherService is in a loading state
            if weatherService.isLoading {
                HStack {
                    ProgressView()
                        .padding(.trailing, 10)
                    Text("Loading weather data...")
                        .font(.system(size: ResponsiveLayout.fontSize(14)))
                        .foregroundColor(AppTheme.textSecondary)
                }
                .frame(height: 100)
                .frame(maxWidth: .infinity, alignment: .center)
            } else if let weather = weatherService.currentWeather {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: getWeatherIcon(for: weather.condition))
                                    .font(.system(size: ResponsiveLayout.fontSize(24)))
                                Text(weather.temperatureString)
                                    .font(.system(size: ResponsiveLayout.fontSize(22), weight: .semibold))
                            }
                            
                            Text("Feels like \(weather.feelsLikeString)")
                                .font(.system(size: ResponsiveLayout.fontSize(14)))
                            
                            Text("Humidity: \(weather.humidityString)")
                                .font(.system(size: ResponsiveLayout.fontSize(12)))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            Text("Wind: \(weather.windSpeedString)")
                                .font(.system(size: ResponsiveLayout.fontSize(12)))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        
                        Spacer()
                        
                        // Weather safety tips
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Safety Tips:")
                                .font(.system(size: ResponsiveLayout.fontSize(14), weight: .medium))
                            
                            Text(getWeatherSafetyTip(for: weather.condition))
                                .font(.system(size: ResponsiveLayout.fontSize(12)))
                                .foregroundColor(AppTheme.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            } else if let error = weatherService.error {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.orange)
                    VStack(alignment: .leading) {
                        Text("Unable to load weather data")
                            .font(.system(size: ResponsiveLayout.fontSize(14)))
                            .foregroundColor(AppTheme.textSecondary)
                        Text(error.localizedDescription)
                            .font(.system(size: ResponsiveLayout.fontSize(12)))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
                .frame(height: 100)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            } else {
                HStack {
                    Image(systemName: "cloud.sun")
                        .foregroundColor(.orange)
                    Text("Weather information will appear here")
                        .font(.system(size: ResponsiveLayout.fontSize(14)))
                        .foregroundColor(AppTheme.textSecondary)
                }
                .frame(height: 100)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(ResponsiveLayout.padding())
        .background(Color.white)
        .cornerRadius(ResponsiveLayout.isIPad ? 20 : 16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
    
    // MARK: - Quick Access Grid
    private func quickAccessGrid(for geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: ResponsiveLayout.padding(12)) {
            Text("Quick Access")
                .font(.system(size: ResponsiveLayout.fontSize(18), weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
            
            LazyVGrid(columns: ResponsiveLayout.gridColumns(), spacing: ResponsiveLayout.padding(16)) {
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
                
                // Settings
                quickAccessButton(
                    title: "Settings",
                    icon: "gear",
                    color: Color(hex: "F9C74F")
                ) {
                    selectedTab = .settings
                }
            }
        }
        .padding(ResponsiveLayout.padding())
        .background(Color.white)
        .cornerRadius(ResponsiveLayout.isIPad ? 20 : 16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 0)
    }
    
    // MARK: - Helper Views
        // Button content helper
        private func quickAccessButtonContent(title: String, icon: String, color: Color) -> some View {
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
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(ResponsiveLayout.padding())
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
        }
        
        private func quickAccessButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
            Button(action: action) {
                quickAccessButtonContent(title: title, icon: icon, color: color)
            }
        }
        
        // MARK: - Helper Methods
        private func loadEmergencyContacts() {
            // Load from UserDefaults instead of CloudKit
            if let data = UserDefaults.standard.data(forKey: "emergencyContacts"),
               let contacts = try? JSONDecoder().decode([EmergencyContact].self, from: data) {
                self.emergencyContacts = contacts
            }
        }
        
        private func getTimeBasedGreeting() -> String {
            let hour = Calendar.current.component(.hour, from: Date())
            
            let greeting: String
            if hour < 12 {
                greeting = "Good Morning"
            } else if hour < 17 {
                greeting = "Good Afternoon"
            } else {
                greeting = "Good Evening"
            }
            
            return greeting
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
