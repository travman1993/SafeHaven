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
//
//  SafeHavenApp.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 2/23/25.
//

import SwiftUI
import CloudKit
import WeatherKit
import CoreLocation
import AuthenticationServices

@main
struct SafeHavenApp: App {
    @StateObject private var cloudKitManager = CloudKitManager.shared
    @StateObject private var authService = AuthenticationService()
    @StateObject private var locationService = LocationService()
    @StateObject private var weatherService = WeatherService.shared // ✅ Use the fixed WeatherService

    var body: some Scene {
        WindowGroup {
            if authService.isSignedIn {
                ContentView()  // Make sure this is ContentView, not EmergencyContactView
                    .environmentObject(cloudKitManager)
                    .environmentObject(authService)
                    .environmentObject(locationService)
                    .environmentObject(weatherService)
            } else {
                LoginView()
                    .environmentObject(authService)
            }
        }
    }
}


struct LoginView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // App Logo and Title
                VStack(spacing: 10) {
                    Image(systemName: "shield.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                    
                    Text("SafeHaven")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Secure Your Safety")
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Error Message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                // Loading or Sign In Button
                if isLoading {
                    ProgressView()
                } else {
                    SignInWithAppleButton(
                        .signIn,
                        onRequest: { request in
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: { result in
                            handleSignInWithApple(result)
                        }
                    )
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)
                    .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
    private func handleSignInWithApple(_ result: Result<ASAuthorization, Error>) {
        isLoading = true
        errorMessage = nil
        
        switch result {
        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                errorMessage = "Authentication failed"
                isLoading = false
                return
            }
            
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            authService.signIn(
                userIdentifier: userIdentifier,
                fullName: fullName,
                email: email
            ) { result in
                DispatchQueue.main.async {
                    isLoading = false
                    
                    switch result {
                    case .success(true):
                        print("Successfully signed in")
                    case .success(false):
                        errorMessage = "Sign-in failed"
                    case .failure(let error):
                        errorMessage = "Error: \(error.localizedDescription)"
                    }
                }
            }
            
        case .failure(let error):
            isLoading = false
            errorMessage = "Authorization failed: \(error.localizedDescription)"
        }
    }
}

// Preview for Xcode
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthenticationService())
    }
}
