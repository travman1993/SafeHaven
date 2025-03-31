//
//  HelpSupportView.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/13/25.
import SwiftUI

struct HelpSupportView: View {
    @State private var showingContactDialog = false
    @State private var selectedCategory: SupportCategory = .general
    @Environment(\.dismiss) var dismiss
    
    enum SupportCategory: String, CaseIterable, Identifiable {
        case general = "General Questions"
        case technical = "Technical Issues"
        case account = "Account Support"
        case emergency = "Emergency Features"
        case feedback = "App Feedback"
        
        var id: String { self.rawValue }
        
        var icon: String {
            switch self {
            case .general: return "questionmark.circle"
            case .technical: return "wrench"
            case .account: return "person.crop.circle"
            case .emergency: return "exclamationmark.shield"
            case .feedback: return "star"
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: ResponsiveLayout.padding(20)) {
                    headerSection()
                    
                    Spacer(minLength: ResponsiveLayout.padding(7))
                    
                    faqsSection()
                    
                    Spacer(minLength: ResponsiveLayout.padding(7))
                    
                    contactSupportSection()
                    
                    Spacer(minLength: ResponsiveLayout.padding(7))
                    
                    communityResourcesSection()
                }
                .frame(
                    maxWidth: geometry.size.width > 600 ? 600 : geometry.size.width * 0.9,
                    alignment: .center
                )
                .padding(.horizontal, ResponsiveLayout.padding())
                .padding(.top, ResponsiveLayout.padding(30))
                .frame(maxWidth: .infinity)
            }
            .background(AppTheme.adaptiveBackground)
        }
        .navigationTitle("Help & Support")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func headerSection() -> some View {
        VStack(spacing: ResponsiveLayout.padding(10)) {
            Image(systemName: "lifepreserver.fill")
                .font(.system(size: ResponsiveLayout.fontSize(55)))
                .foregroundColor(AppTheme.primary)
                .padding(.top, ResponsiveLayout.padding(15))
            
            Text("How can we help?")
                .font(.system(size: ResponsiveLayout.fontSize(22), weight: .bold))
                .foregroundColor(AppTheme.adaptiveTextPrimary)
            
            Text("Find answers or reach out for support")
                .font(.system(size: ResponsiveLayout.fontSize(16)))
                .foregroundColor(AppTheme.adaptiveTextSecondary)
        }
        .padding(.bottom, ResponsiveLayout.padding(8))
    }
    
    private func faqsSection() -> some View {
        VStack(alignment: .leading, spacing: ResponsiveLayout.padding(15)) {
            Text("Frequently Asked Questions")
                .font(.system(size: ResponsiveLayout.fontSize(18), weight: .bold))
                .foregroundColor(AppTheme.adaptiveTextPrimary)
                .padding(.horizontal, ResponsiveLayout.padding())
            
            VStack(spacing: ResponsiveLayout.padding(12)) {
                FAQItem(
                    question: "How do I add emergency contacts?",
                    answer: "To add emergency contacts, go to the Profile tab, select 'Emergency Contacts', then tap the '+' button to add a new contact. Enter their name, phone number, and relationship."
                )
                
                FAQItem(
                    question: "What happens when I use the emergency slider?",
                    answer: "When you use the emergency slider, the app will initiate a call to emergency services (911) and send text messages with your current location to your designated emergency contacts."
                )
            }
            .frame(maxWidth: 600) // Ensures consistent width
            .background(AppTheme.adaptiveCardBackground)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
            .padding(.horizontal, ResponsiveLayout.padding())
        }
    }

    private func contactSupportSection() -> some View {
        VStack(alignment: .center, spacing: ResponsiveLayout.padding(15)) {
            Text("Contact Support")
                .font(.system(size: ResponsiveLayout.fontSize(18), weight: .bold))
                .foregroundColor(AppTheme.adaptiveTextPrimary)
                .padding(.horizontal, ResponsiveLayout.padding())
            
            Button(action: {
                showingContactDialog = true
            }) {
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(AppTheme.primary)
                    Text("Email Support")
                        .foregroundColor(AppTheme.adaptiveTextPrimary)
                }
                .padding()
                .background(AppTheme.adaptiveCardBackground)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
            }
        }
        .frame(maxWidth: 600) // Ensures consistent width
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func communityResourcesSection() -> some View {
        VStack(alignment: .leading, spacing: ResponsiveLayout.padding(15)) {
            Text("Community Resources")
                .font(.system(size: ResponsiveLayout.fontSize(18), weight: .bold))
                .foregroundColor(AppTheme.adaptiveTextPrimary)
                .padding(.horizontal, ResponsiveLayout.padding())

            VStack(spacing: ResponsiveLayout.padding(12)) {
                CommunityResourceItem(
                    title: "Find Local Shelters",
                    description: "Browse a list of nearby shelters and safe spaces available in your area.",
                    icon: "house.fill",
                    url: "https://www.homelessshelterdirectory.org/"
                )

                CommunityResourceItem(
                    title: "Food Assistance Programs",
                    description: "Find food banks and meal programs to help with daily nutrition.",
                    icon: "cart.fill",
                    url: "https://www.feedingamerica.org/find-your-local-foodbank"
                )

                CommunityResourceItem(
                    title: "Mental Health Support",
                    description: "Get access to mental health resources, including crisis hotlines and counseling services.",
                    icon: "brain.head.profile",
                    url: "https://www.nami.org/help"
                )
            }
            .frame(maxWidth: 600) // Ensures uniform width
            .background(AppTheme.adaptiveCardBackground)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
            .padding(.horizontal, ResponsiveLayout.padding())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// FAQ Item View
struct FAQItem: View {
    let question: String
    let answer: String
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(question)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.adaptiveTextPrimary)
            
            if isExpanded {
                Text(answer)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.adaptiveTextSecondary)
            }
            
            Button(action: { isExpanded.toggle() }) {
                Text(isExpanded ? "Hide" : "Show more")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.primary)
            }
        }
        .padding()
    }
}

// Community Resource Item View
struct CommunityResourceItem: View {
    let title: String
    let description: String
    let icon: String
    let url: String

    var body: some View {
        VStack(alignment: .leading, spacing: ResponsiveLayout.padding(6)) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(AppTheme.primary)
                    .font(.system(size: 22))
                
                Text(title)
                    .font(.system(size: ResponsiveLayout.fontSize(15), weight: .bold))
                    .foregroundColor(AppTheme.adaptiveTextPrimary)
            }

            Text(description)
                .font(.system(size: ResponsiveLayout.fontSize(13)))
                .foregroundColor(AppTheme.adaptiveTextSecondary)

            Button(action: {
                if let link = URL(string: url) {
                    UIApplication.shared.open(link)
                }
            }) {
                Text("Visit Website")
                    .font(.system(size: ResponsiveLayout.fontSize(13), weight: .medium))
                    .foregroundColor(AppTheme.primary)
            }
        }
    }
}
