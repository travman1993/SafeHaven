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
        NavigationStack {
            ScrollView {
                VStack(spacing: ResponsiveLayout.padding(24)) {
                    // App Appearance
                    appearanceSection()
                    
                    // Notifications
                    notificationsSection()
                    
                    // Data & Privacy
                    privacySection()
                    
                    // About & Support
                    aboutSupportSection()
                    
                    // App info
                    appInfoSection()
                }
                .padding(.vertical, ResponsiveLayout.padding())
            }
            .background(AppTheme.adaptiveBackground)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func appearanceSection() -> some View {
        VStack(alignment: .leading, spacing: ResponsiveLayout.padding(16)) {
            Text("App Appearance")
                .font(.system(
                    size: ResponsiveLayout.fontSize(18),
                    weight: .bold
                ))
                .padding(.horizontal, ResponsiveLayout.padding())
                .foregroundColor(AppTheme.adaptiveTextPrimary)
            
            VStack(spacing: ResponsiveLayout.padding(16)) {
                // Theme Colors
                Text("Accent Color")
                    .font(.system(
                        size: ResponsiveLayout.fontSize(14)
                    ))
                    .foregroundColor(AppTheme.adaptiveTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, ResponsiveLayout.padding())
                
                // Color Grid
                LazyVGrid(
                    columns: ResponsiveLayout.isIPad
                        ? Array(repeating: GridItem(.flexible()), count: 5)
                        : Array(repeating: GridItem(.flexible()), count: 3),
                    spacing: ResponsiveLayout.padding(12)
                ) {
                    ForEach(colorOptions) { option in
                        Button(action: {
                            accentColorString = option.hex
                            updateAppAccentColor(option.hex)
                        }) {
                            VStack(spacing: ResponsiveLayout.padding(8)) {
                                Circle()
                                    .fill(Color(hex: option.hex))
                                    .frame(
                                        width: ResponsiveLayout.isIPad ? 54 : 44,
                                        height: ResponsiveLayout.isIPad ? 54 : 44
                                    )
                                    .overlay(
                                        accentColorString == option.hex ?
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.white)
                                            .font(.system(size: ResponsiveLayout.fontSize(14)))
                                        : nil
                                    )
                                
                                Text(option.name)
                                    .font(.system(
                                        size: ResponsiveLayout.fontSize(12)
                                    ))
                                    .foregroundColor(AppTheme.adaptiveTextPrimary)
                            }
                        }
                    }
                }
                .padding(.horizontal, ResponsiveLayout.padding())
                
                // UI Settings
                Text("UI Settings")
                    .font(.system(
                        size: ResponsiveLayout.fontSize(14)
                    ))
                    .foregroundColor(AppTheme.adaptiveTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, ResponsiveLayout.padding())
                    .padding(.top, ResponsiveLayout.padding(8))
                
                VStack(spacing: 0) {
                    SettingsToggle(title: "Reduce Motion", isOn: $reduceMotion)
                    Divider()
                        .padding(.leading, ResponsiveLayout.isIPad ? 60 : 50)
                    SettingsToggle(title: "Bold Text", isOn: $boldText)
                }
                .padding(.horizontal, ResponsiveLayout.padding())
                .background(AppTheme.adaptiveCardBackground)
                .cornerRadius(ResponsiveLayout.isIPad ? 16 : 12)
                .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
                .padding(.horizontal, ResponsiveLayout.padding())
            }
        }
    }
    
    private func notificationsSection() -> some View {
        VStack(alignment: .leading, spacing: ResponsiveLayout.padding(16)) {
            Text("Notifications")
                .font(.system(
                    size: ResponsiveLayout.fontSize(18),
                    weight: .bold
                ))
                .padding(.horizontal, ResponsiveLayout.padding())
                .foregroundColor(AppTheme.adaptiveTextPrimary)
            
            NavigationLink(destination: NotificationSettingsView()) {
                settingsRowContent(
                    icon: "bell.badge",
                    title: "Notification Settings"
                )
            }
            .padding(.horizontal, ResponsiveLayout.padding())
        }
    }
    
    private func privacySection() -> some View {
        VStack(alignment: .leading, spacing: ResponsiveLayout.padding(16)) {
            Text("Data & Privacy")
                .font(.system(
                    size: ResponsiveLayout.fontSize(18),
                    weight: .bold
                ))
                .padding(.horizontal, ResponsiveLayout.padding())
                .foregroundColor(AppTheme.adaptiveTextPrimary)
            
            NavigationLink(destination: PrivacySettingsView()) {
                settingsRowContent(
                    icon: "lock.shield",
                    title: "Privacy Settings"
                )
            }
            .padding(.horizontal, ResponsiveLayout.padding())
        }
    }
    
    private func aboutSupportSection() -> some View {
        VStack(alignment: .leading, spacing: ResponsiveLayout.padding(16)) {
            Text("About & Support")
                .font(.system(
                    size: ResponsiveLayout.fontSize(18),
                    weight: .bold
                ))
                .padding(.horizontal, ResponsiveLayout.padding())
                .foregroundColor(AppTheme.adaptiveTextPrimary)
            
            VStack(spacing: 0) {
                NavigationLink(destination: AboutSafeHavenView()) {
                    settingsRowContent(
                        icon: "info.circle",
                        title: "About SafeHaven"
                    )
                }
                
                Divider()
                    .padding(.leading, ResponsiveLayout.isIPad ? 60 : 50)
                
                NavigationLink(destination: DeveloperStoryView()) {
                    settingsRowContent(
                        icon: "person.text.rectangle",
                        title: "Developer Story"
                    )
                }
                
                Divider()
                    .padding(.leading, ResponsiveLayout.isIPad ? 60 : 50)
                
                NavigationLink(destination: HelpSupportView()) {
                    settingsRowContent(
                        icon: "questionmark.circle",
                        title: "Help & Support"
                    )
                }
                
                Divider()
                    .padding(.leading, ResponsiveLayout.isIPad ? 60 : 50)
                
                Button(action: {
                    showingSupportersView = true
                }) {
                    settingsRowContent(
                        icon: "star.circle",
                        title: "Supporters"
                    )
                }
            }
            .background(AppTheme.adaptiveCardBackground)
            .cornerRadius(ResponsiveLayout.isIPad ? 16 : 12)
            .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
            .padding(.horizontal, ResponsiveLayout.padding())
        }
    }
    
    private func settingsRowContent(icon: String, title: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(AppTheme.primary)
                .frame(width: ResponsiveLayout.isIPad ? 36 : 24,
                       height: ResponsiveLayout.isIPad ? 36 : 24)
            
            Text(title)
                .font(.system(
                    size: ResponsiveLayout.fontSize(16)
                ))
                .foregroundColor(AppTheme.adaptiveTextPrimary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(AppTheme.adaptiveTextSecondary)
                .font(.system(size: ResponsiveLayout.fontSize(14)))
        }
        .padding(ResponsiveLayout.padding())
    }
    
    private func appInfoSection() -> some View {
        VStack {
            Image(systemName: "shield.fill")
                .font(.system(
                    size: ResponsiveLayout.fontSize(40)
                ))
                .foregroundColor(AppTheme.primary)
                .padding(.top, ResponsiveLayout.padding(20))
            
            Text("SafeHaven")
                .font(.system(
                    size: ResponsiveLayout.fontSize(18),
                    weight: .bold
                ))
                .foregroundColor(AppTheme.adaptiveTextPrimary)
            
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
            Text("Version \(version)")
                .font(.system(
                    size: ResponsiveLayout.fontSize(14)
                ))
                .foregroundColor(AppTheme.adaptiveTextSecondary)
            
            Text("© 2025 SafeHaven")
                .font(.system(
                    size: ResponsiveLayout.fontSize(12)
                ))
                .foregroundColor(AppTheme.adaptiveTextSecondary)
                .padding(.top, ResponsiveLayout.padding(4))
                .padding(.bottom, ResponsiveLayout.padding(20))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, ResponsiveLayout.padding(20))
    }
    
    private func updateAppAccentColor(_ hexColor: String) {
        AppTheme.primary = Color(hex: hexColor)
    }
}

// Separate SettingsToggle struct
struct SettingsToggle: View {
    var title: String
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(title, isOn: $isOn)
            .foregroundColor(AppTheme.adaptiveTextPrimary)
            .toggleStyle(SwitchToggleStyle(tint: AppTheme.primary))
            .padding(ResponsiveLayout.padding())
    }
}
