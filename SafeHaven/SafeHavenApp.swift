//
//  SafeHavenApp.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 2/23/25.
//

//
//  SafeHavenApp.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 2/23/25.
//
import Foundation
import SwiftUI
import CloudKit
import WeatherKit
import CoreLocation
import AuthenticationServices

@main
struct SafeHavenApp: App {
    @StateObject private var cloudKitManager = CloudKitManager()
    @StateObject private var authService = AuthenticationService()
    @StateObject private var locationService = LocationService()
    @StateObject private var weatherService = WeatherService()
    
    var body: some Scene {
        WindowGroup {
            if authService.isSignedIn {
                ContentView()
                    .environmentObject(cloudKitManager)
                    .environmentObject(authService)
                    .environmentObject(locationService)
                    .environmentObject(weatherService)
            } else {
                LoginView()
                    .environmentObject(authService)
            }
        }
        .onChange(of: locationService.currentLocation) { newLocation in
            if let location = newLocation {
                weatherService.fetchWeather(for: location)
            }
        }
    }
}

// LoginView for Sign in with Apple
struct LoginView: View {
    @EnvironmentObject var authService: AuthenticationService
    
    var body: some View {
        VStack {
            Text("SafeHaven")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Secure Your Safety")
                .foregroundColor(.secondary)
            
            Spacer()
            
            SignInWithAppleButton(
                .signIn,
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { result in
                    switch result {
                    case .success(let authorization):
                        authService.signIn { result in
                            switch result {
                            case .success(let signedIn):
                                print("Successfully signed in: \(signedIn)")
                            case .failure(let error):
                                print("Sign in error: \(error.localizedDescription)")
                            }
                        }
                    case .failure(let error):
                        print("Authorization failed: \(error.localizedDescription)")
                    }
                }
            )
            .signInWithAppleButtonStyle(.black)
            .frame(width: 280, height: 60)
            .cornerRadius(10)
            
            Spacer()
        }
        .padding()
    }
}

// Updated ContentView to use new services
struct ContentView: View {
    @EnvironmentObject var cloudKitManager: CloudKitManager
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var locationService: LocationService
    @EnvironmentObject var weatherService: WeatherService
    
    var body: some View {
        TabView {
            // Main app content with tabs
            MainDashboardView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            EmergencyContactView()
                .tabItem {
                    Label("Contacts", systemImage: "person.2")
                }
            
            WeatherDashboardView()
                .tabItem {
                    Label("Weather", systemImage: "cloud.sun")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}

// Placeholder views - you'll need to implement these
struct MainDashboardView: View {
    var body: some View {
        Text("Main Dashboard")
    }
}

struct WeatherDashboardView: View {
    @EnvironmentObject var weatherService: WeatherService
    @EnvironmentObject var locationService: LocationService
    
    var body: some View {
        VStack {
            if let currentWeather = weatherService.currentWeather {
                Text("Current Weather")
                    .font(.title)
                
                Image(systemName: weatherService.getWeatherIcon(currentWeather.condition))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                
                Text(weatherService.getWeatherConditionDescription(currentWeather.condition))
                
                Text(weatherService.formatTemperature(currentWeather.temperature))
                    .font(.largeTitle)
                
                Text(locationService.formattedAddress())
                    .foregroundColor(.secondary)
            } else {
                ProgressView("Fetching Weather")
            }
        }
        .onAppear {
            if let location = locationService.currentLocation {
                weatherService.fetchWeather(for: location)
            } else {
                locationService.requestLocation()
            }
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject var authService: AuthenticationService
    
    var body: some View {
        VStack {
            Text("Profile")
                .font(.title)
            
            if let fullName = authService.fullName {
                Text(PersonNameComponentsFormatter.localizedString(from: fullName, style: .default))
            }
            
            if let email = authService.userEmail {
                Text(email)
                    .foregroundColor(.secondary)
            }
            
            Button("Sign Out") {
                authService.signOut()
            }
            .foregroundColor(.red)
        }
    }
}
