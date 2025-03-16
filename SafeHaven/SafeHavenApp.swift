//
//  SafeHavenApp.swift
//  SafeHaven
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
    @StateObject private var weatherService = WeatherService.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    init() {
        // Set feature flags for the subscription manager
        if UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
            // Set up notification observer for showing paywall
            NotificationCenter.default.addObserver(
                forName: Notification.Name("ShowPaywall"),
                object: nil,
                queue: .main
            ) { _ in
                // This will be handled in ContentView
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if authService.isSignedIn {
                ContentView()
                    .environmentObject(cloudKitManager)
                    .environmentObject(authService)
                    .environmentObject(locationService)
                    .environmentObject(weatherService)
            } else {
                LoginViewContent()
                    .environmentObject(authService)
            }
        }
    }
}

struct LoginViewContent: View {
    @EnvironmentObject var authService: AuthenticationService
    
    // Define all state variables at the struct level
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingOnboarding = false
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfService = false
    
    var body: some View {
        Group {
            if showingOnboarding {
                // Use your existing OnboardingView - no onComplete parameter
                OnboardingView(hasCompletedOnboarding: $showingOnboarding, onComplete: {
                    signInAsGuest()
                })
                    .onChange(of: showingOnboarding) { oldValue, newValue in
                        if oldValue == true && newValue == false {
                            // When onboarding completes
                            signInAsGuest()
                        }
                    }
            } else {
                loginContent
            }
        }
        .sheet(isPresented: $showingPrivacyPolicy) {
            NavigationView {
                PrivacyPolicyView()
                    .navigationBarTitle("Privacy Policy", displayMode: .inline)
                    .navigationBarItems(trailing: Button("Done") {
                        showingPrivacyPolicy = false
                    })
            }
        }
        .sheet(isPresented: $showingTermsOfService) {
            NavigationView {
                TermsOfServiceView()
                    .navigationBarTitle("Terms of Service", displayMode: .inline)
                    .navigationBarItems(trailing: Button("Done") {
                        showingTermsOfService = false
                    })
            }
        }
    }
    
    private var loginContent: some View {
        VStack(spacing: 30) {
            // App Logo and Title
            VStack(spacing: 16) {
                // App logo
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "5A89CC"), Color(hex: "41B3A3")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 130, height: 130)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    
                    // Shield icon with house and heart
                    Image(systemName: "shield.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Image(systemName: "house.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                    
                    Image(systemName: "heart.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                        .offset(y: 10)
                }
                .padding(.top, 60)
                .padding(.bottom, 10)
                
                Text("SafeHaven")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("Secure Your Safety")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.textSecondary)
                    .padding(.bottom, 20)
                
                Text("Find resources and emergency assistance when you need them most")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }
            .padding(.bottom, 40)
            
            // Error Message
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.bottom, 10)
            }
            
            // Loading or Sign In Button
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .padding(.bottom, 20)
            } else {
                VStack(spacing: 16) {
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
                    .cornerRadius(12)
                    .padding(.horizontal, 30)
                    
                    Button(action: {
                        // Show onboarding for guest users
                        showingOnboarding = true
                    }) {
                        Text("Continue as Guest")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.primary)
                    }
                    .padding(.top, 8)
                }
            }
            
            Spacer()
            
            // Footer with functional links
            VStack(spacing: 10) {
                Text("By continuing, you agree to our")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                
                HStack(spacing: 4) {
                    Button(action: {
                        showingTermsOfService = true
                    }) {
                        Text("Terms of Service")
                            .font(.caption)
                            .foregroundColor(AppTheme.primary)
                            .underline()
                    }
                    
                    Text("and")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Button(action: {
                        showingPrivacyPolicy = true
                    }) {
                        Text("Privacy Policy")
                            .font(.caption)
                            .foregroundColor(AppTheme.primary)
                            .underline()
                    }
                }
            }
            .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.background.ignoresSafeArea())
    }
    
    // Function to handle Apple Sign In
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
                        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
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
    
    // Function to sign in as guest
    func signInAsGuest() {
        // Create a guest user with demo credentials
        authService.signIn(
            userIdentifier: "guest-user",
            fullName: PersonNameComponents(givenName: "Guest", familyName: "User"),
            email: "guest@example.com"
        ) { result in
            // Check the result explicitly
            if case .success(true) = result {
                // Set the onboarding flag
                UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                print("Successfully signed in as guest")
            } else {
                print("Failed to sign in as guest")
            }
        }
    }
}
