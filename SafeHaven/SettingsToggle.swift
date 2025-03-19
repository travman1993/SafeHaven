//
//  SettingsToggle.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/19/25.
//
import SwiftUI

struct SettingsToggle: View {
    var title: String
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(isOn: $isOn) {
            Text(title)
                .foregroundColor(AppTheme.textPrimary)
        }
        .toggleStyle(SwitchToggleStyle(tint: AppTheme.primary))
    }
}
