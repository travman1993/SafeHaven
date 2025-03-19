//
//  SupportersView.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/19/25.
import SwiftUI

struct SupportersView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                ScrollView {
                    VStack(spacing: ResponsiveLayout.padding(30)) {
                        // Header image
                        Image(systemName: "heart.fill")
                            .font(.system(size: ResponsiveLayout.fontSize(70)))
                            .foregroundColor(AppTheme.primary)
                            .padding(.top, ResponsiveLayout.padding(20))
                        
                        Text("Support SafeHaven")
                            .font(.system(
                                size: ResponsiveLayout.fontSize(32),
                                weight: .bold
                            ))
                        
                        Text("Help us continue developing and improving SafeHaven")
                            .font(.system(size: ResponsiveLayout.fontSize(16)))
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, ResponsiveLayout.padding(30))
                        
                        // Mission card
                        missionSection(in: geometry)
                        
                        // Partner with us section
                        partnerSection(in: geometry)
                        
                        // Current supporters section
                        supportersSection(in: geometry)
                        
                        Spacer(minLength: ResponsiveLayout.padding(40))
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
    
    private func missionSection(in geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: ResponsiveLayout.padding(16)) {
            Text("Our Mission")
                .font(.system(
                    size: ResponsiveLayout.fontSize(18),
                    weight: .bold
                ))
            
            VStack(spacing: ResponsiveLayout.padding(12)) {
                Text("SafeHaven was created to provide essential resources to those in need. We believe that everyone deserves access to safety information and support services when they need it most.")
                    .font(.system(size: ResponsiveLayout.fontSize(16)))
                    .foregroundColor(AppTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("As an independent developer project, we rely on community support to keep improving and adding new features.")
                    .font(.system(size: ResponsiveLayout.fontSize(16)))
                    .foregroundColor(AppTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(ResponsiveLayout.padding())
            .background(Color.white)
            .cornerRadius(ResponsiveLayout.isIPad ? 20 : 16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
            .padding(.horizontal, ResponsiveLayout.padding())
        }
    }
    
    private func partnerSection(in geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: ResponsiveLayout.padding(16)) {
            Text("Partner With Us")
                .font(.system(
                    size: ResponsiveLayout.fontSize(18),
                    weight: .bold
                ))
            
            VStack(spacing: ResponsiveLayout.padding(12)) {
                Text("Are you an organization that provides services to people in need? Partner with SafeHaven to reach those who need your help.")
                    .font(.system(size: ResponsiveLayout.fontSize(16)))
                    .foregroundColor(AppTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                Button(action: {
                    // Open email to contact about partnerships
                    if let url = URL(string: "mailto:partnerships@safehaven-app.com") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Contact Us About Partnerships")
                        .font(.system(
                            size: ResponsiveLayout.fontSize(16),
                            weight: .medium
                        ))
                        .foregroundColor(.white)
                        .padding(ResponsiveLayout.padding())
                        .frame(maxWidth: .infinity)
                        .background(AppTheme.primary)
                        .cornerRadius(ResponsiveLayout.isIPad ? 16 : 10)
                }
            }
            .padding(ResponsiveLayout.padding())
            .background(Color.white)
            .cornerRadius(ResponsiveLayout.isIPad ? 20 : 16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
            .padding(.horizontal, ResponsiveLayout.padding())
        }
    }
    
    private func supportersSection(in geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: ResponsiveLayout.padding(16)) {
            Text("Current Supporters")
                .font(.system(
                    size: ResponsiveLayout.fontSize(18),
                    weight: .bold
                ))
            
            VStack(spacing: ResponsiveLayout.padding(12)) {
                Text("We'll be launching our official partner program soon. Check back to see organizations who are supporting our mission.")
                    .font(.system(size: ResponsiveLayout.fontSize(16)))
                    .foregroundColor(AppTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Placeholder for future sponsorships
                ZStack {
                    RoundedRectangle(cornerRadius: ResponsiveLayout.isIPad ? 16 : 12)
                        .fill(Color(hex: "F5F7FA"))
                        .frame(height: ResponsiveLayout.isIPad ? 150 : 100)
                    
                    Text("Your organization could be featured here")
                        .font(.system(size: ResponsiveLayout.fontSize(14)))
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            .padding(ResponsiveLayout.padding())
            .background(Color.white)
            .cornerRadius(ResponsiveLayout.isIPad ? 20 : 16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
            .padding(.horizontal, ResponsiveLayout.padding())
        }
    }
}

#Preview {
    SupportersView()
}
