//
//  LocationSelectorView.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 4/4/25.
//
import SwiftUI
import CoreLocation

// City selector view for when location permissions are denied
struct LocationSelectorView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedCity: DefaultLocation?
    let defaultCities: [DefaultLocation]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(defaultCities) { city in
                    Button(action: {
                        selectedCity = city
                        dismiss()
                    }) {
                        HStack {
                            Text(city.name)
                                .foregroundColor(AppTheme.adaptiveTextPrimary)
                            
                            Spacer()
                            
                            if let selected = selectedCity, selected.name == city.name {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppTheme.primary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select City")
            .navigationBarItems(trailing: Button("Close") {
                dismiss()
            })
        }
    }
}

// View that shows when location permissions are denied
struct LocationPermissionView: View {
    @Binding var showingLocationSelector: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "location.slash")
                .font(.system(size: 50))
                .foregroundColor(AppTheme.primary.opacity(0.7))
            
            Text("Location Services Disabled")
                .font(.headline)
                .foregroundColor(AppTheme.adaptiveTextPrimary)
            
            Text("You can still use SafeHaven without location services. Select a city manually to find resources near that location.")
                .multilineTextAlignment(.center)
                .foregroundColor(AppTheme.adaptiveTextSecondary)
                .padding(.horizontal)
            
            Button(action: {
                showingLocationSelector = true
            }) {
                Text("Choose a City")
                    .fontWeight(.medium)
                    .padding()
                    .foregroundColor(.white)
                    .background(AppTheme.primary)
                    .cornerRadius(10)
            }
            .padding(.top)
            
            Button(action: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Enable Location in Settings")
                    .fontWeight(.medium)
                    .padding()
                    .foregroundColor(AppTheme.adaptiveTextPrimary)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppTheme.adaptiveCardBackground)
        )
        .padding()
    }
}
