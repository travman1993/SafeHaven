//
//  DeveloperStoryView.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 2/27/25.
//
import SwiftUI

struct DeveloperStoryView: View {
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: ResponsiveLayout.padding(24)) {
                    // Header image and title
                    headerSection(in: geometry)
                    
                    // Personal story sections
                    personalStorySection(in: geometry)
                    
                    // Development journey with milestone cards
                    developmentJourneySection(in: geometry)
                    
                    // Message to supporters
                    supporterMessageSection(in: geometry)
                }
                .padding(ResponsiveLayout.padding())
            }
            .background(Color(hex: "F5F7FA").ignoresSafeArea())
        }
        .navigationTitle("Developer Story")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func headerSection(in geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "6A89CC"), Color(hex: "41B3A3")]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(
                        width: ResponsiveLayout.isIPad ? 180 : 120,
                        height: ResponsiveLayout.isIPad ? 180 : 120
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                
                Image(systemName: "person.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(
                        width: ResponsiveLayout.isIPad ? 80 : 60,
                        height: ResponsiveLayout.isIPad ? 80 : 60
                    )
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(.top, ResponsiveLayout.padding(30))
            .padding(.bottom, ResponsiveLayout.padding(16))
            
            Text("Meet the Developer")
                .font(.system(
                    size: ResponsiveLayout.fontSize(28),
                    weight: .bold,
                    design: .rounded
                ))
                .foregroundColor(Color(hex: "2D3748"))
                .padding(.bottom, ResponsiveLayout.padding(4))
            
            Text("Travis Rodriguez")
                .font(.system(
                    size: ResponsiveLayout.fontSize(20),
                    weight: .semibold,
                    design: .rounded
                ))
                .foregroundColor(Color(hex: "6A89CC"))
                .padding(.bottom, ResponsiveLayout.padding(20))
        }
        .frame(maxWidth: .infinity)
    }
    
    private func personalStorySection(in geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: ResponsiveLayout.padding(16)) {
            storySection(
                title: "My Journey",
                content: "I'm a single father who started with nothing but a dream to make a difference. Growing up with limited resources taught me the value of resilience and community support. These experiences inspired me to learn iOS development, turning challenges into motivation to build tools that can help others facing similar situations."
            )
            
            storySection(
                title: "Why SafeHaven?",
                content: "The idea for SafeHaven came from my own experiences navigating difficult times. I realized how valuable it would have been to have a single resource that connected people with all the support services available to them. I wanted to create something that could serve as a lifeline for others when they need it most."
            )
            
            storySection(
                title: "The Vision",
                content: "SafeHaven began as a personal project to help people find resources during challenging times. As a self-taught developer, each feature represents countless hours of learning and determination. My dream is to grow this app into a platform that not only provides information but also delivers direct support to those in need."
            )
        }
    }
    
    private func developmentJourneySection(in geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: ResponsiveLayout.padding(16)) {
            Text("Development Journey")
                .font(.system(
                    size: ResponsiveLayout.fontSize(20),
                    weight: .bold
                ))
                .foregroundColor(Color(hex: "2D3748"))
                .padding(.bottom, ResponsiveLayout.padding(8))
            
            VStack(spacing: ResponsiveLayout.padding(16)) {
                milestoneCard(
                    title: "Starting from Scratch",
                    date: "2023",
                    description: "Began learning Swift and iOS development while balancing work and being a single parent."
                )
                
                milestoneCard(
                    title: "First Prototype",
                    date: "2025",
                    description: "Created the initial version of SafeHaven with basic resource location features."
                )
                
                milestoneCard(
                    title: "App Launch",
                    date: "2025",
                    description: "Released SafeHaven to the public with the mission of connecting people with vital resources."
                )
                
                milestoneCard(
                    title: "Future Goals",
                    date: "2027+",
                    description: "Expanding SafeHaven to include direct assistance programs and building a support network for users."
                )
            }
            .padding(ResponsiveLayout.padding())
            .background(
                RoundedRectangle(cornerRadius: ResponsiveLayout.isIPad ? 20 : 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
        }
    }
    
    private func supporterMessageSection(in geometry: GeometryProxy) -> some View {
        VStack(spacing: ResponsiveLayout.padding(16)) {
            Text("A Message to Supporters")
                .font(.system(
                    size: ResponsiveLayout.fontSize(20),
                    weight: .bold
                ))
                .foregroundColor(Color(hex: "2D3748"))
            
            Text("Your support means more than just funding app development. It represents belief in the mission of SafeHaven and in my journey as a developer striving to make a difference. Every contribution helps build a better future for this platform and ultimately for the people it will serve. Thank you for being part of this journey.")
                .font(.system(size: ResponsiveLayout.fontSize(16)))
                .foregroundColor(Color(hex: "4A5568"))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal)
            
            Button(action: {
                // Open Stripe donation link
                if let url = URL(string: "https://buy.stripe.com/yourStripeAccountDonationLink") {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Support Our Mission")
                    .font(.system(
                        size: ResponsiveLayout.fontSize(16),
                        weight: .semibold
                    ))
                    .foregroundColor(.white)
                    .padding(.vertical, ResponsiveLayout.isIPad ? 18 : 14)
                    .padding(.horizontal, ResponsiveLayout.isIPad ? 32 : 24)
                    .background(Color(hex: "41B3A3"))
                    .cornerRadius(ResponsiveLayout.isIPad ? 16 : 12)
                    .shadow(color: Color(hex: "41B3A3").opacity(0.4), radius: 4, x: 0, y: 2)
            }
            .padding(.top, ResponsiveLayout.padding(8))
        }
        .padding(ResponsiveLayout.padding())
        .background(
            RoundedRectangle(cornerRadius: ResponsiveLayout.isIPad ? 20 : 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .padding(.vertical, ResponsiveLayout.padding(10))
    }
    
    // Helper Views
    private func storySection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: ResponsiveLayout.padding(10)) {
            Text(title)
                .font(.system(
                    size: ResponsiveLayout.fontSize(20),
                    weight: .bold
                ))
                .foregroundColor(Color(hex: "2D3748"))
            
            Text(content)
                .font(.system(size: ResponsiveLayout.fontSize(16)))
                .foregroundColor(Color(hex: "4A5568"))
                .lineSpacing(4)
        }
        .padding(ResponsiveLayout.padding())
        .background(
            RoundedRectangle(cornerRadius: ResponsiveLayout.isIPad ? 20 : 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
    
    private func milestoneCard(title: String, date: String, description: String) -> some View {
        HStack(alignment: .top, spacing: ResponsiveLayout.padding(16)) {
            // Date circle
            VStack {
                ZStack {
                    Circle()
                        .fill(Color(hex: "6A89CC").opacity(0.2))
                        .frame(
                            width: ResponsiveLayout.isIPad ? 54 : 45,
                            height: ResponsiveLayout.isIPad ? 54 : 45
                        )
                    
                    Text(date)
                        .font(.system(
                            size: ResponsiveLayout.fontSize(12),
                            weight: .bold
                        ))
                        .foregroundColor(Color(hex: "6A89CC"))
                }
                
                if description != "" {
                    Rectangle()
                        .fill(Color(hex: "E2E8F0"))
                        .frame(width: 2, height: ResponsiveLayout.isIPad ? 60 : 40)
                }
            }
            
            VStack(alignment: .leading, spacing: ResponsiveLayout.padding(6)) {
                Text(title)
                    .font(.system(
                        size: ResponsiveLayout.fontSize(16),
                        weight: .semibold
                    ))
                    .foregroundColor(Color(hex: "2D3748"))
                
                Text(description)
                    .font(.system(size: ResponsiveLayout.fontSize(14)))
                    .foregroundColor(Color(hex: "718096"))
                    .lineSpacing(3)
            }
        }
        .padding(.vertical, ResponsiveLayout.padding(8))
    }
}
