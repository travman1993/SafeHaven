//
//  DeveloperStoryView.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 2/27/25.
//
import SwiftUI

struct DeveloperStoryView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header image and title
                VStack(spacing: 0) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .frame(width: 120, height: 120)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "6A89CC"), Color(hex: "41B3A3")]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Circle())
                        .padding(.top, 30)
                        .padding(.bottom, 16)
                    
                    Text("Meet the Developer")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "2D3748"))
                        .padding(.bottom, 4)
                    
                    Text("Travis Rodriguez")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(hex: "6A89CC"))
                        .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity)
                
                // Personal story
                StorySection(
                    title: "My Journey",
                    content: "I'm a single father who started with nothing but a dream to make a difference. Growing up with limited resources taught me the value of resilience and community support. These experiences inspired me to learn iOS development, turning challenges into motivation to build tools that can help others facing similar situations."
                )
                
                StorySection(
                    title: "Why SafeHaven?",
                    content: "The idea for SafeHaven came from my own experiences navigating difficult times. I realized how valuable it would have been to have a single resource that connected people with all the support services available to them. I wanted to create something that could serve as a lifeline for others when they need it most."
                )
                
                StorySection(
                    title: "The Vision",
                    content: "SafeHaven began as a personal project to help people find resources during challenging times. As a self-taught developer, each feature represents countless hours of learning and determination. My dream is to grow this app into a platform that not only provides information but also delivers direct support to those in need."
                )
                
                // Development journey with milestone cards
                VStack(alignment: .leading, spacing: 16) {
                    Text("Development Journey")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(hex: "2D3748"))
                        .padding(.bottom, 8)
                    
                    MilestoneCard(
                        title: "Starting from Scratch",
                        date: "2023",
                        description: "Began learning Swift and iOS development while balancing work and being a single parent."
                    )
                    
                    MilestoneCard(
                        title: "First Prototype",
                        date: "2025",
                        description: "Created the initial version of SafeHaven with basic resource location features."
                    )
                    
                    MilestoneCard(
                        title: "App Launch",
                        date: "2025",
                        description: "Released SafeHaven to the public with the mission of connecting people with vital resources."
                    )
                    
                    MilestoneCard(
                        title: "Future Goals",
                        date: "2027+",
                        description: "Expanding SafeHaven to include direct assistance programs and building a support network for users."
                    )
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                )
                
                // Message to supporters
                VStack(spacing: 16) {
                    Text("A Message to Supporters")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(hex: "2D3748"))
                    
                    Text("Your support means more than just funding app development. It represents belief in the mission of SafeHaven and in my journey as a developer striving to make a difference. Every contribution helps build a better future for this platform and ultimately for the people it will serve. Thank you for being part of this journey.")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "4A5568"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal)
                    
                    Button(action: {
                        // Navigate back to support page
                        // This is handled by the NavigationView system
                    }) {
                        Text("Support Our Mission")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 24)
                            .background(Color(hex: "41B3A3"))
                            .cornerRadius(12)
                            .shadow(color: Color(hex: "41B3A3").opacity(0.4), radius: 4, x: 0, y: 2)
                    }
                    .padding(.top, 8)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                )
                .padding(.vertical, 10)
            }
            .padding()
        }
        .background(Color(hex: "F5F7FA").ignoresSafeArea())
        .navigationTitle("Developer Story")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StorySection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(hex: "2D3748"))
            
            Text(content)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "4A5568"))
                .lineSpacing(4)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

struct MilestoneCard: View {
    let title: String
    let date: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Date circle
            VStack {
                ZStack {
                    Circle()
                        .fill(Color(hex: "6A89CC").opacity(0.2))
                        .frame(width: 45, height: 45)
                    
                    Text(date)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: "6A89CC"))
                }
                
                if description != "" {
                    Rectangle()
                        .fill(Color(hex: "E2E8F0"))
                        .frame(width: 2, height: 40)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "2D3748"))
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "718096"))
                    .lineSpacing(3)
            }
        }
        .padding(.vertical, 8)
    }
}
