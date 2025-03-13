//
//  HelpSupportView.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/13/25.
//
import SwiftUI

struct HelpSupportView: View {
    @State private var showingContactDialog = false
    @State private var selectedCategory = SupportCategory.general
    
    enum SupportCategory: String, CaseIterable, Identifiable {
        case general = "General Questions"
        case technical = "Technical Issues"
        case account = "Account Support"
        case emergency = "Emergency Features"
        case feedback = "App Feedback"
        
        var id: String { self.rawValue }
        
        var icon: String {
            switch self {
            case .general: return "questionmark.circle.fill"
            case .technical: return "wrench.fill"
            case .account: return "person.crop.circle.fill"
            case .emergency: return "exclamationmark.shield.fill"
            case .feedback: return "star.fill"
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Support header
                VStack(spacing: 12) {
                    Image(systemName: "lifepreserver.fill")
                        .font(.system(size: 60))
                        .foregroundColor(AppTheme.primary)
                        .padding(.top, 20)
                    
                    Text("How can we help?")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Find answers or reach out for support")
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding(.bottom, 10)
                
                // FAQs section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Frequently Asked Questions")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    FAQItem(question: "How do I add emergency contacts?",
                           answer: "To add emergency contacts, go to the Profile tab, select 'Emergency Contacts', then tap the '+' button to add a new contact. Enter their name, phone number, and relationship.")
                    
                    FAQItem(question: "What happens when I use the emergency slider?",
                           answer: "When you use the emergency slider, the app will initiate a call to emergency services (911) and send text messages with your current location to your designated emergency contacts.")
                    
                    FAQItem(question: "How accurate are the resource locations?",
                           answer: "Resource locations are regularly updated and verified. However, hours of operation and specific services may change. We recommend calling ahead to confirm details before visiting.")
                    
                    FAQItem(question: "Is my journal data private?",
                           answer: "Yes, your journal entries are stored securely and privately. They are only accessible from your account and are not shared with anyone.")
                    
                    FAQItem(question: "How do I reset my password?",
                           answer: "To reset your password, log out of the app, then tap 'Forgot Password' on the login screen. Follow the instructions sent to your registered email address.")
                }
                
                // Contact support section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Contact Support")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        Button(action: {
                            showingContactDialog = true
                        }) {
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                    .frame(width: 36, height: 36)
                                    .background(AppTheme.primary)
                                    .clipShape(Circle())
                                
                                Text("Email Support")
                                    .font(.headline)
                                    .foregroundColor(AppTheme.textPrimary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color(hex: "A0AEC0"))
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Response Times")
                                .font(.headline)
                            
                            Text("• General questions: 1-2 business days\n• Technical issues: 24-48 hours\n• Account support: 24-48 hours\n• Emergency features: Priority support")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                                    }
                                    
                                    // Community resources section
                                    VStack(alignment: .leading, spacing: 16) {
                                        Text("Community Resources")
                                            .font(.headline)
                                            .padding(.horizontal)
                                        
                                        VStack(spacing: 16) {
                                            LinkButton(
                                                icon: "books.vertical.fill",
                                                title: "Knowledge Base",
                                                description: "Browse our comprehensive guides and tutorials",
                                                action: {
                                                    if let url = URL(string: "https://safehaven-app.com/help") {
                                                        UIApplication.shared.open(url)
                                                    }
                                                }
                                            )
                                            
                                            LinkButton(
                                                icon: "bubble.left.and.bubble.right.fill",
                                                title: "Community Forum",
                                                description: "Connect with other users and share experiences",
                                                action: {
                                                    if let url = URL(string: "https://forum.safehaven-app.com") {
                                                        UIApplication.shared.open(url)
                                                    }
                                                }
                                            )
                                            
                                            LinkButton(
                                                icon: "video.fill",
                                                title: "Video Tutorials",
                                                description: "Watch step-by-step guides for using the app",
                                                action: {
                                                    if let url = URL(string: "https://safehaven-app.com/tutorials") {
                                                        UIApplication.shared.open(url)
                                                    }
                                                }
                                            )
                                        }
                                        .padding(.horizontal)
                                    }
                                    
                                    Spacer(minLength: 40)
                                }
                                .padding(.horizontal)
                            }
                            .background(AppTheme.background.ignoresSafeArea())
                            .navigationTitle("Help & Support")
                            .navigationBarTitleDisplayMode(.inline)
                            .actionSheet(isPresented: $showingContactDialog) {
                                ActionSheet(
                                    title: Text("Contact Support"),
                                    message: Text("Please select a category for your support request"),
                                    buttons: [
                                        .default(Text("General Questions")) {
                                            sendEmail(category: .general)
                                        },
                                        .default(Text("Technical Issues")) {
                                            sendEmail(category: .technical)
                                        },
                                        .default(Text("Account Support")) {
                                            sendEmail(category: .account)
                                        },
                                        .default(Text("Emergency Features")) {
                                            sendEmail(category: .emergency)
                                        },
                                        .default(Text("App Feedback")) {
                                            sendEmail(category: .feedback)
                                        },
                                        .cancel()
                                    ]
                                )
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

                    struct FAQItem: View {
                        let question: String
                        let answer: String
                        @State private var isExpanded = false
                        
                        var body: some View {
                            VStack(alignment: .leading, spacing: 12) {
                                Button(action: {
                                    withAnimation {
                                        isExpanded.toggle()
                                    }
                                }) {
                                    HStack {
                                        Text(question)
                                            .font(.headline)
                                            .foregroundColor(AppTheme.textPrimary)
                                            .multilineTextAlignment(.leading)
                                        
                                        Spacer()
                                        
                                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                            .foregroundColor(AppTheme.primary)
                                            .animation(.spring(), value: isExpanded)
                                    }
                                }
                                
                                if isExpanded {
                                    Text(answer)
                                        .font(.subheadline)
                                        .foregroundColor(AppTheme.textSecondary)
                                        .padding(.top, 4)
                                        .transition(.move(edge: .top).combined(with: .opacity))
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
                            .padding(.horizontal)
                        }
                    }

                    struct LinkButton: View {
                        let icon: String
                        let title: String
                        let description: String
                        let action: () -> Void
                        
                        var body: some View {
                            Button(action: action) {
                                HStack(spacing: 16) {
                                    Image(systemName: icon)
                                        .font(.system(size: 18))
                                        .foregroundColor(.white)
                                        .frame(width: 36, height: 36)
                                        .background(AppTheme.primary)
                                        .clipShape(Circle())
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(title)
                                            .font(.headline)
                                            .foregroundColor(AppTheme.textPrimary)
                                        
                                        Text(description)
                                            .font(.caption)
                                            .foregroundColor(AppTheme.textSecondary)
                                            .multilineTextAlignment(.leading)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.up.right")
                                        .foregroundColor(Color(hex: "A0AEC0"))
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
                            }
                        }
                    }
