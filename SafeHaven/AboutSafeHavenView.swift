//
//  AboutSafeHavenView.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/13/25.
//
import SwiftUI

struct AboutSafeHavenView: View {
    @State private var appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // App logo and version
                VStack(spacing: 12) {
                    Image(systemName: "shield.fill")
                        .font(.system(size: 80))
                        .foregroundColor(AppTheme.primary)
                        .padding(.top, 20)
                    
                    Text("SafeHaven")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Version \(appVersion)")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding()
                
                // App description
                VStack(alignment: .leading, spacing: 16) {
                    Text("About")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Text("SafeHaven is designed to help individuals quickly find resources and emergency assistance when they need them most. Our mission is to provide a safe, accessible platform that connects people with vital services during challenging times.")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                }
                
                // Features
                VStack(alignment: .leading, spacing: 16) {
                    Text("Key Features")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        FeatureItem(icon: "exclamationmark.shield.fill", title: "Emergency SOS", description: "Quick access to emergency services with location sharing and contact notifications")
                        
                        FeatureItem(icon: "mappin.and.ellipse", title: "Resource Finder", description: "Locate nearby shelters, food banks, healthcare, and other support services")
                        
                        FeatureItem(icon: "cloud.sun.fill", title: "Weather & Safety", description: "Real-time weather with safety recommendations based on conditions")
                        
                        FeatureItem(icon: "book.fill", title: "Personal Journal", description: "Track your thoughts, feelings, and progress with a private journal")
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                }
                
                // Support section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Support")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        Button(action: {
                            if let url = URL(string: "mailto:support@safehaven-app.com") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(AppTheme.primary)
                                Text("Contact Support")
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "A0AEC0"))
                            }
                            .padding()
                            .contentShape(Rectangle())
                        }
                        
                        Divider()
                            .padding(.leading, 50)
                        
                        Button(action: {
                            if let url = URL(string: "https://safehaven-app.com/faq") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack {
                                Image(systemName: "questionmark.circle.fill")
                                    .foregroundColor(AppTheme.primary)
                                Text("Frequently Asked Questions")
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "A0AEC0"))
                            }
                            .padding()
                            .contentShape(Rectangle())
                        }
                        
                        Divider()
                            .padding(.leading, 50)
                        
                        Button(action: {
                            if let url = URL(string: "https://safehaven-app.com") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack {
                                Image(systemName: "globe")
                                    .foregroundColor(AppTheme.primary)
                                Text("Visit Website")
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "A0AEC0"))
                            }
                            .padding()
                            .contentShape(Rectangle())
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                }
                
                // Legal section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Legal")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        NavigationLink(destination: PrivacyPolicyView()) {
                            HStack {
                                Image(systemName: "lock.shield.fill")
                                    .foregroundColor(AppTheme.primary)
                                Text("Privacy Policy")
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "A0AEC0"))
                            }
                            .padding()
                        }
                        
                        Divider()
                            .padding(.leading, 50)
                        
                        NavigationLink(destination: TermsOfServiceView()) {
                            HStack {
                                Image(systemName: "doc.text.fill")
                                    .foregroundColor(AppTheme.primary)
                                Text("Terms of Service")
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "A0AEC0"))
                            }
                            .padding()
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                }
                
                Text("© 2025 SafeHaven. All rights reserved.")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                    .padding(.top, 10)
                    .padding(.bottom, 40)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FeatureItem: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(AppTheme.primary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
