//
//  SettingsView.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/19/25.
//
import SwiftUI

struct SettingsView: View {
    @Binding var showingSupportersView: Bool
    @AppStorage("accentColorString") private var accentColorString = "4A76D4"
    @AppStorage("reduceMotion") private var reduceMotion = false
    @AppStorage("boldText") private var boldText = false
    
    // Theme color options
    private let colorOptions = [
        ColorOption(name: "Blue", hex: "4A76D4"),
        ColorOption(name: "Teal", hex: "36A599"),
        ColorOption(name: "Rose", hex: "E8505B"),
        ColorOption(name: "Purple", hex: "7952B3"),
        ColorOption(name: "Orange", hex: "F9844A")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // App Appearance
                    VStack(alignment: .leading, spacing: 16) {
                        Text("App Appearance")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            // Theme Colors
                            Text("Accent Color")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Color Grid
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                                ForEach(colorOptions) { option in
                                    Button(action: {
                                        accentColorString = option.hex
                                        updateAppAccentColor(option.hex)
                                    }) {
                                        VStack(spacing: 8) {
                                            Circle()
                                                .fill(Color(hex: option.hex))
                                                .frame(width: 44, height: 44)
                                                .overlay(
                                                    accentColorString == option.hex ?
                                                    Image(systemName: "checkmark")
                                                        .foregroundColor(.white)
                                                    : nil
                                                )
                                            
                                            Text(option.name)
                                                .font(.caption)
                                                .foregroundColor(AppTheme.textPrimary)
                                        }
                                    }
                                }
                            }
                            
                            // UI Settings
                            Text("UI Settings")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 8)
                            
                            SettingsToggle(title: "Reduce Motion", isOn: $reduceMotion)
                            SettingsToggle(title: "Bold Text", isOn: $boldText)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                    
                    // Notifications
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Notifications")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        NavigationLink(destination: NotificationSettingsView()) {
                            SettingsRow(
                                icon: "bell.badge",
                                title: "Notification Settings",
                                description: "Configure notification preferences"
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Data & Privacy
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Data & Privacy")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        NavigationLink(destination: PrivacySettingsView()) {
                            SettingsRow(
                                icon: "lock.shield",
                                title: "Privacy Settings",
                                description: "Manage location data and privacy options"
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // About & Support
                    VStack(alignment: .leading, spacing: 16) {
                        Text("About & Support")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            NavigationLink(destination: AboutSafeHavenView()) {
                                HStack {
                                    Image(systemName: "info.circle")
                                        .foregroundColor(AppTheme.primary)
                                        .frame(width: 24, height: 24)
                                    
                                    Text("About SafeHaven")
                                        .foregroundColor(AppTheme.textPrimary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color(hex: "A0AEC0"))
                                }
                                .padding()
                            }
                            
                            Divider()
                                .padding(.leading, 56)
                            
                            NavigationLink(destination: DeveloperStoryView()) {
                                HStack {
                                    Image(systemName: "person.text.rectangle")
                                        .foregroundColor(AppTheme.primary)
                                        .frame(width: 24, height: 24)
                                    
                                    Text("Developer Story")
                                        .foregroundColor(AppTheme.textPrimary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color(hex: "A0AEC0"))
                                }
                                .padding()
                            }
                            
                            Divider()
                                .padding(.leading, 56)
                            
                            NavigationLink(destination: HelpSupportView()) {
                                HStack {
                                    Image(systemName: "questionmark.circle")
                                        .foregroundColor(AppTheme.primary)
                                        .frame(width: 24, height: 24)
                                    
                                    Text("Help & Support")
                                        .foregroundColor(AppTheme.textPrimary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color(hex: "A0AEC0"))
                                }
                                .padding()
                            }
                            
                            Divider()
                                .padding(.leading, 56)
                            
                            Button(action: {
                                showingSupportersView = true
                            }) {
                                HStack {
                                    Image(systemName: "star.circle")
                                        .foregroundColor(AppTheme.primary)
                                        .frame(width: 24, height: 24)
                                    
                                    Text("Supporters")
                                        .foregroundColor(AppTheme.textPrimary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
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
                    
                    // App info
                    VStack {
                        Image(systemName: "shield.fill")
                            .font(.system(size: 40))
                            .foregroundColor(AppTheme.primary)
                            .padding(.top, 20)
                        
                        Text("SafeHaven")
                            .font(.headline)
                        
                        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
                        Text("Version \(version)")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                        
                        Text("© 2025 SafeHaven")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                            .padding(.top, 4)
                            .padding(.bottom, 20)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                }
                .padding(.vertical)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func updateAppAccentColor(_ hexColor: String) {
        AppTheme.primary = Color(hex: hexColor)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppTheme.primary)
                .frame(width: 36, height: 36)
                .background(AppTheme.primary.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Color(hex: "A0AEC0"))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}
