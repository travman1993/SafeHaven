//
//  AboutSafeHavenView.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/13/25.
import SwiftUI

struct AboutSafeHavenView: View {
    @State private var appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: ResponsiveLayout.padding(24)) {
                    // App logo and version
                    headerSection(in: geometry)
                    
                    // App description
                    descriptionSection(in: geometry)
                    
                    // Features section
                    featuresSection(in: geometry)
                    
                    // Support section
                    supportSection(in: geometry)
                    
                    // Legal section
                    legalSection(in: geometry)
                    
                    // Copyright
                    copyrightSection(in: geometry)
                }
                .padding(ResponsiveLayout.padding())
            }
            .background(AppTheme.adaptiveBackground.ignoresSafeArea())
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func headerSection(in geometry: GeometryProxy) -> some View {
        VStack(spacing: ResponsiveLayout.padding(12)) {
            Image(systemName: "shield.fill")
                .font(.system(
                    size: ResponsiveLayout.fontSize(80)
                ))
                .foregroundColor(AppTheme.primary)
                .padding(.top, ResponsiveLayout.padding(20))
            
            Text("SafeHaven")
                .font(.system(
                    size: ResponsiveLayout.fontSize(24),
                    weight: .bold
                ))
                .foregroundColor(AppTheme.adaptiveTextPrimary)
            
            Text("Version \(appVersion)")
                .font(.system(
                    size: ResponsiveLayout.fontSize(14)
                ))
                .foregroundColor(AppTheme.adaptiveTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(ResponsiveLayout.padding())
        .background(AppTheme.adaptiveCardBackground)
        .cornerRadius(ResponsiveLayout.isIPad ? 20 : 16)
    }
    
    private func descriptionSection(in geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: ResponsiveLayout.padding(16)) {
            Text("About")
                .font(.system(
                    size: ResponsiveLayout.fontSize(18),
                    weight: .bold
                ))
                .foregroundColor(AppTheme.adaptiveTextPrimary)
                .padding(.horizontal, ResponsiveLayout.padding())
            
            Text("SafeHaven is designed to help individuals quickly find resources and emergency assistance when they need them most. Our mission is to provide a safe, accessible platform that connects people with vital services during challenging times.")
                .font(.system(
                    size: ResponsiveLayout.fontSize(16),
                    weight: .regular
                ))
                .foregroundColor(AppTheme.adaptiveTextSecondary)
                .padding(ResponsiveLayout.padding())
                .background(AppTheme.adaptiveCardBackground)
                .cornerRadius(ResponsiveLayout.isIPad ? 20 : 16)
        }
    }
    
    private func featuresSection(in geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: ResponsiveLayout.padding(16)) {
            Text("Key Features")
                .font(.system(
                    size: ResponsiveLayout.fontSize(18),
                    weight: .bold
                ))
                .foregroundColor(AppTheme.adaptiveTextPrimary)
                .padding(.horizontal, ResponsiveLayout.padding())
            
            VStack(spacing: ResponsiveLayout.padding(16)) {
                featureItem(
                    icon: "exclamationmark.shield.fill",
                    title: "Emergency SOS",
                    description: "Quick access to emergency services with location sharing and contact notifications"
                )
                
                featureItem(
                    icon: "mappin.and.ellipse",
                    title: "Resource Finder",
                    description: "Locate nearby shelters, food banks, healthcare, and other support services"
                )
                
                featureItem(
                    icon: "cloud.sun.fill",
                    title: "Weather & Safety",
                    description: "Real-time weather with safety recommendations based on conditions"
                )
                
                featureItem(
                    icon: "book.fill",
                    title: "Personal Journal",
                    description: "Track your thoughts, feelings, and progress with a private journal"
                )
                
                featureItem(
                    icon: "quote.bubble.fill",
                    title: "Daily Motivation",
                    description: "Get inspirational quotes to boost your mood and motivation daily"
                )
            }
            .padding(ResponsiveLayout.padding())
            .background(AppTheme.adaptiveCardBackground)
            .cornerRadius(ResponsiveLayout.isIPad ? 20 : 16)
        }
    }
    
    private func supportSection(in geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: ResponsiveLayout.padding(16)) {
            Text("Support")
                .font(.system(
                    size: ResponsiveLayout.fontSize(18),
                    weight: .bold
                ))
                .foregroundColor(AppTheme.adaptiveTextPrimary)
                .padding(.horizontal, ResponsiveLayout.padding())
            
            VStack(spacing: 0) {
                supportContactButton(
                    icon: "envelope.fill",
                    title: "Contact Support",
                    urlString: "mailto:support@safehaven-app.com"
                )
                
                Divider()
                    .padding(.leading, ResponsiveLayout.isIPad ? 60 : 50)
                
                supportContactButton(
                    icon: "globe",
                    title: "Visit Website",
                    urlString: "https://safehaven.cc"
                )
            }
            .background(AppTheme.adaptiveCardBackground)
            .cornerRadius(ResponsiveLayout.isIPad ? 20 : 16)
        }
    }
    
    private func legalSection(in geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: ResponsiveLayout.padding(16)) {
            Text("Legal")
                .font(.system(
                    size: ResponsiveLayout.fontSize(18),
                    weight: .bold
                ))
                .foregroundColor(AppTheme.adaptiveTextPrimary)
                .padding(.horizontal, ResponsiveLayout.padding())
            
            VStack(spacing: 0) {
                NavigationLink(destination: PrivacyPolicyView()) {
                    legalItemContent(
                        icon: "lock.shield.fill",
                        title: "Privacy Policy"
                    )
                }
                
                Divider()
                    .padding(.leading, ResponsiveLayout.isIPad ? 60 : 50)
                
                NavigationLink(destination: TermsOfServiceView()) {
                    legalItemContent(
                        icon: "doc.text.fill",
                        title: "Terms of Service"
                    )
                }
            }
            .background(AppTheme.adaptiveCardBackground)
            .cornerRadius(ResponsiveLayout.isIPad ? 20 : 16)
        }
    }
    
    private func copyrightSection(in geometry: GeometryProxy) -> some View {
        Text("© 2025 SafeHaven. All rights reserved.")
            .font(.system(
                size: ResponsiveLayout.fontSize(12)
            ))
            .foregroundColor(AppTheme.adaptiveTextSecondary)
            .padding(.top, ResponsiveLayout.padding(10))
            .padding(.bottom, ResponsiveLayout.padding(40))
    }
    
    // Helper Views
    private func featureItem(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: ResponsiveLayout.padding(16)) {
            Image(systemName: icon)
                .font(.system(
                    size: ResponsiveLayout.fontSize(22)
                ))
                .foregroundColor(AppTheme.primary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: ResponsiveLayout.padding(4)) {
                Text(title)
                    .font(.system(
                        size: ResponsiveLayout.fontSize(16),
                        weight: .semibold
                    ))
                    .foregroundColor(AppTheme.adaptiveTextPrimary)
                
                Text(description)
                    .font(.system(
                        size: ResponsiveLayout.fontSize(14),
                        weight: .regular
                    ))
                    .foregroundColor(AppTheme.adaptiveTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    private func supportContactButton(icon: String, title: String, urlString: String) -> some View {
        Button(action: {
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
        }) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(AppTheme.primary)
                Text(title)
                    .foregroundColor(AppTheme.adaptiveTextPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: ResponsiveLayout.fontSize(14)))
                    .foregroundColor(AppTheme.adaptiveTextSecondary)
            }
            .padding(ResponsiveLayout.padding())
        }
    }
    
    private func legalItemContent(icon: String, title: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(AppTheme.primary)
            Text(title)
                .foregroundColor(AppTheme.adaptiveTextPrimary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: ResponsiveLayout.fontSize(14)))
                .foregroundColor(AppTheme.adaptiveTextSecondary)
        }
        .padding(ResponsiveLayout.padding())
    }
}
