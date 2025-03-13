//
//  AppearanceSettingsView.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/13/25.
//
import SwiftUI

struct AppearanceSettingsView: View {
    @AppStorage("useSystemTheme") private var useSystemTheme = true
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @AppStorage("accentColorString") private var accentColorString = "6A89CC" // Default blue
    
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
                Toggle("Reduce Motion", isOn: .constant(false))
                Toggle("Reduce Transparency", isOn: .constant(false))
                Toggle("Bold Text", isOn: .constant(false))
            }
            
            Section(footer: Text("These settings will be applied when you restart the app.")) {
                Button("Reset to Defaults") {
                    useSystemTheme = true
                    darkModeEnabled = false
                    accentColorString = "6A89CC"
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ColorOption: Identifiable {
    let id = UUID()
    let name: String
    let hex: String
}
