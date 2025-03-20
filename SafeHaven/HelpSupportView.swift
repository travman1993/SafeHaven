//
//  HelpSupportView.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/13/25.
import SwiftUI

struct HelpSupportView: View {
    @State private var showingContactDialog = false
    @State private var selectedCategory: SupportCategory = .general
    
    // Define SupportCategory as a full type
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
            NavigationView {
                ScrollView {
                    VStack(spacing: ResponsiveLayout.padding(24)) {
                        // Header section
                        headerSection()
                        
                        // FAQs section
                        faqsSection()
                        
                        // Contact support section
                        contactSupportSection()
                        
                        // Community resources section
                        communityResourcesSection()
                    }
                    .padding(.horizontal, ResponsiveLayout.padding())
                }
                .background(AppTheme.background.ignoresSafeArea())
                .navigationTitle("Help & Support")
                .navigationBarTitleDisplayMode(.inline)
            }
            .actionSheet(isPresented: $showingContactDialog) {
                ActionSheet(
                    title: Text("Contact Support"),
                    message: Text("Please select a category for your support request"),
                    buttons: SupportCategory.allCases.map { category in
                        .default(Text(category.rawValue)) {
                            sendEmail(category: category)
                        }
                    } + [.cancel()]
                )
            }
        }
    }
    
    private func headerSection() -> some View {
        VStack(spacing: ResponsiveLayout.padding(12)) {
            Image(systemName: "lifepreserver.fill")
                .font(.system(size: ResponsiveLayout.fontSize(60)))
                .foregroundColor(AppTheme.primary)
                .padding(.top, ResponsiveLayout.padding(20))
            
            Text("How can we help?")
                .font(.system(
                    size: ResponsiveLayout.fontSize(22),
                    weight: .bold
                ))
            
            Text("Find answers or reach out for support")
                .font(.system(size: ResponsiveLayout.fontSize(16)))
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(.bottom, ResponsiveLayout.padding(10))
    }
    
    private func faqsSection() -> some View {
        VStack(alignment: .leading, spacing: ResponsiveLayout.padding(16)) {
            Text("Frequently Asked Questions")
                .font(.system(
                    size: ResponsiveLayout.fontSize(18),
                    weight: .bold
                ))
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
        }
    }
    
    private func contactSupportSection() -> some View {
        VStack(alignment: .leading, spacing: ResponsiveLayout.padding(16)) {
            Text("Contact Support")
                .font(.system(
                    size: ResponsiveLayout.fontSize(18),
                    weight: .bold
                ))
                .padding(.horizontal, ResponsiveLayout.padding())
            
            Button(action: {
                showingContactDialog = true
            }) {
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(AppTheme.primary)
                    Text("Email Support")
                }
            }
        }
    }
    
    private func communityResourcesSection() -> some View {
        VStack(alignment: .leading, spacing: ResponsiveLayout.padding(16)) {
            Text("Community Resources")
                .font(.system(
                    size: ResponsiveLayout.fontSize(18),
                    weight: .bold
                ))
                .padding(.horizontal, ResponsiveLayout.padding())
            
            // Add community resources content
        }
    }
    
    private func sendEmail(category: SupportCategory) {
        let subject = "SafeHaven Support - \(category.rawValue)"
        let body = "Please describe your issue or question below:\n\n"
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let url = URL(string: "mailto:support@safehaven-app.com?subject=\(encodedSubject)&body=\(encodedBody)") {
            UIApplication.shared.open(url)
        }
    }
}

// FAQ Item View (you'll need to implement this separately)
struct FAQItem: View {
    let question: String
    let answer: String
    @State private var isExpanded = false
    
    var body: some View {
        VStack {
            Text(question)
            if isExpanded {
                Text(answer)
            }
            Button(action: { isExpanded.toggle() }) {
                Text(isExpanded ? "Hide" : "Show more")
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
}
