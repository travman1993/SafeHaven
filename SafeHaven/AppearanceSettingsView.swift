import SwiftUI

class AccessibilityManager {
    static func updateReduceMotion(_ enabled: Bool) {
        // You cannot directly set this property
        // Instead, provide guidance or use system settings
        print("Reduce Motion setting: \(enabled)")
        // Optionally open Settings if you want to guide user
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    static func updateBoldText(_ enabled: Bool) {
        // Similar approach for Bold Text
        print("Bold Text setting: \(enabled)")
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    // Getter methods to check current state
    static var isReduceMotionEnabled: Bool {
        UIAccessibility.isReduceMotionEnabled
    }
    
    static var isBoldTextEnabled: Bool {
        UIAccessibility.isBoldTextEnabled
    }
}

struct AppearanceSettingsView: View {
    @AppStorage("useSystemTheme") private var useSystemTheme = true
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @AppStorage("accentColorString") private var accentColorString = "6A89CC"
    @AppStorage("reduceMotion") private var reduceMotion = false
    @AppStorage("boldText") private var boldText = false
    
    private let colorOptions = [
        ColorOption(name: "Blue", hex: "6A89CC"),
        ColorOption(name: "Teal", hex: "41B3A3"),
        ColorOption(name: "Rose", hex: "E8505B"),
        ColorOption(name: "Purple", hex: "7952B3"),
        ColorOption(name: "Orange", hex: "F9844A")
    ]
    var body: some View {
        Form {
            Section(header: Text("Theme")) {
                Toggle("Use System Settings", isOn: $useSystemTheme)
                
                if !useSystemTheme {
                    Toggle("Dark Mode", isOn: $darkModeEnabled)
                        .disabled(useSystemTheme)
                }
            }
            
            Section(header: Text("Accent Color")) {
                ForEach(colorOptions) { option in
                    Button(action: {
                        accentColorString = option.hex
                        updateAppAccentColor(option.hex)
                    }) {
                        HStack {
                            Circle()
                                .fill(Color(hex: option.hex))
                                .frame(width: 24, height: 24)
                            
                            Text(option.name)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if accentColorString == option.hex {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppTheme.primary)
                            }
                        }
                    }
                }
            }
            
            Section(header: Text("UI Settings"), footer: Text("These settings affect the appearance of cards and elements in the app.")) {
                            Toggle("Reduce Motion", isOn: $reduceMotion)
                                .onChange(of: reduceMotion) { oldValue, newValue in
                                    AccessibilityManager.updateReduceMotion(newValue)
                                }
                            
                            Toggle("Reduce Transparency", isOn: $reduceMotion)
                            
                            Toggle("Bold Text", isOn: $boldText)
                                .onChange(of: boldText) { oldValue, newValue in
                                    AccessibilityManager.updateBoldText(newValue)
                                }
                        }
            
            Section(footer: Text("These settings will be applied when you restart the app.")) {
                Button("Reset to Defaults") {
                    resetToDefaults()
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func updateAppAccentColor(_ hexColor: String) {
        AppTheme.primary = Color(hex: hexColor)
    }
    
    private func resetToDefaults() {
        useSystemTheme = true
        darkModeEnabled = false
        accentColorString = "6A89CC"
        reduceMotion = false
        boldText = false
        
        updateAppAccentColor("6A89CC")
    }
}

struct ColorOption: Identifiable {
    let id = UUID()
    let name: String
    let hex: String
}
