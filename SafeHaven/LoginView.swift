//
//  LoginView.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/12/25.
import Foundation
import SwiftUI
import CloudKit
import WeatherKit
import CoreLocation
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            // Background color
            Color(UIColor.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)
            
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
                        .foregroundColor(.primary)
                    
                    Text("Secure Your Personal Safety")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Error Message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding()
                }
                
                // Sign In with Apple Button
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
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
                    .padding(.horizontal)
                }
                
                // Additional Information
                VStack(spacing: 10) {
                    Text("By signing in, you agree to our")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Link("Terms of Service", destination: URL(string: "https://yourwebsite.com/terms")!)
                        Text("and")
                        Link("Privacy Policy", destination: URL(string: "https://yourwebsite.com/privacy")!)
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                .padding()
            }
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding()
        }
    }
    
    private func handleSignInWithApple(_ result: Result<ASAuthorization, Error>) {
        isLoading = true
        errorMessage = nil
        
        switch result {
        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                errorMessage = "Authentication failed. Please try again."
                isLoading = false
                return
            }
            
            // Extract credential information
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            // Attempt to sign in
            authService.signIn(
                userIdentifier: userIdentifier,
                fullName: fullName,
                email: email
            ) { result in
                DispatchQueue.main.async {
                    isLoading = false
                    
                    switch result {
                    case .success(true):
                        // Authentication successful
                        print("Successfully signed in")
                    case .success(false):
                        errorMessage = "Sign-in failed. Please try again."
                    case .failure(let error):
                        errorMessage = "Error: \(error.localizedDescription)"
                    }
                }
            }
            
        case .failure(let error):
            // Handle sign-in error
            DispatchQueue.main.async {
                isLoading = false
                errorMessage = "Sign-in failed: \(error.localizedDescription)"
            }
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
