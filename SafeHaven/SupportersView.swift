//
//  SupportersView.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/19/25.
//

import SwiftUI

struct SupportersView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Header image
                    Image(systemName: "heart.fill")
                        .font(.system(size: 70))
                        .foregroundColor(AppTheme.primary)
                        .padding(.top, 20)
                    
                    Text("Support SafeHaven")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Help us continue developing and improving SafeHaven")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                    
                    // Mission card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Our Mission")
                            .font(.headline)
                        
                        Text("SafeHaven was created to provide essential resources to those in need. We believe that everyone deserves access to safety information and support services when they need it most.")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text("As an independent developer project, we rely on community support to keep improving and adding new features.")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
                    .padding(.horizontal)
                    
                    // Partner with us section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Partner With Us")
                            .font(.headline)
                        
                        Text("Are you an organization that provides services to people in need? Partner with SafeHaven to reach those who need your help.")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Button(action: {
                            // Open email to contact about partnerships
                            if let url = URL(string: "mailto:partnerships@safehaven-app.com") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Text("Contact Us About Partnerships")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(AppTheme.primary)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
                    .padding(.horizontal)
                    
                    // Current supporters (placeholder for future sponsors)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Current Supporters")
                            .font(.headline)
                        
                        Text("We'll be launching our official partner program soon. Check back to see organizations who are supporting our mission.")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // Placeholder for future sponsorships
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "F5F7FA"))
                                .frame(height: 100)
                            
                            Text("Your organization could be featured here")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                }
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Supporters")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Close") {
                dismiss()
            })
        }
    }
}

#Preview {
    SupportersView()
}
