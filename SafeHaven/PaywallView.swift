//
//  PaywallView.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/1/25.
//
import Foundation
import SwiftUI
import CloudKit
import WeatherKit
import CoreLocation
import AuthenticationServices
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var isProcessing = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "star.square.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color(hex: "6A89CC"))
                            .padding(.top, 20)
                        
                        Text("Safe Haven Premium")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "2D3748"))
                        
                        Text("Access all premium features")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(Color(hex: "6A89CC"))
                    }
                    
                    // Feature List
                    VStack(alignment: .leading, spacing: 20) {
                        FeatureRow(
                            icon: "book.fill",
                            title: "Daily Journal",
                            description: "Track your mood and thoughts with a personal journal"
                        )
                        
                        FeatureRow(
                            icon: "checklist",
                            title: "Todo List",
                            description: "Organize your daily tasks with a simple todo list"
                        )
                        
                        FeatureRow(
                            icon: "quote.bubble.fill",
                            title: "Daily Motivation",
                            description: "Access personalized motivational quotes and inspiration"
                        )
                        
                        FeatureRow(
                            icon: "person.crop.circle.badge.exclamationmark",
                            title: "Emergency Contacts",
                            description: "Set up contacts to notify in case of emergency"
                        )
                        
                        FeatureRow(
                            icon: "exclamationmark.shield.fill",
                            title: "Emergency SOS",
                            description: "Quick access to emergency services with automated texts"
                        )
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    )
                    .padding(.horizontal)
                    
                    // Pricing Section
                    VStack(spacing: 16) {
                        if subscriptionManager.isLoading {
                            ProgressView()
                                .padding()
                        } else if let product = subscriptionManager.products.first {
                            // Subscription option
                            VStack(spacing: 10) {
                                Text("Monthly Premium")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color(hex: "2D3748"))
                                
                                Text("\(product.displayPrice) / month")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(Color(hex: "6A89CC"))
                                
                                Text("Cancel anytime")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "718096"))
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(hex: "F5F7FA"))
                                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            )
                            .padding(.horizontal)
                            
                            // Subscribe button
                            Button(action: {
                                purchaseSubscription(product: product)
                            }) {
                                if isProcessing {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Subscribe Now")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(hex: "6A89CC"))
                            )
                            .padding(.horizontal)
                            .disabled(isProcessing)
                        } else {
                            // No products available
                            Text("Subscription information unavailable")
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "718096"))
                                .multilineTextAlignment(.center)
                                .padding()
                            
                            Button(action: {
                                Task {
                                    await subscriptionManager.loadProducts()
                                }
                            }) {
                                Text("Refresh")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 24)
                                    .background(Color(hex: "6A89CC"))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.vertical)
                    
                    // Benefits
                    Text("Subscribers help us continue developing new features and maintaining the service.")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "718096"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    // Space for terms
                    VStack(spacing: 8) {
                        Text("Subscription automatically renews unless cancelled")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "A0AEC0"))
                        
                        HStack(spacing: 16) {
                            Button(action: {
                                // Link to terms
                            }) {
                                Text("Terms of Service")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color(hex: "6A89CC"))
                            }
                            
                            Button(action: {
                                // Link to privacy policy
                            }) {
                                Text("Privacy Policy")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color(hex: "6A89CC"))
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
                .padding(.vertical)
            }
            .background(Color(hex: "F5F7FA").ignoresSafeArea())
            .navigationBarTitle("Premium Features", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "718096"))
            })
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Subscription"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .onAppear {
            if subscriptionManager.products.isEmpty {
                Task {
                    await subscriptionManager.loadProducts()
                }
            }
        }
    }
    
    private func purchaseSubscription(product: Product) {
        isProcessing = true
        
        Task {
            let success = await subscriptionManager.purchase(product)
            
            // Update UI on main thread
            DispatchQueue.main.async {
                isProcessing = false
                if success {
                    alertMessage = "Thank you for subscribing to Safe Haven Premium!"
                    showAlert = true
                    // Dismiss the paywall after a short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        dismiss()
                    }
                } else {
                    alertMessage = "There was an issue processing your subscription. Please try again."
                    showAlert = true
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(Color(hex: "6A89CC"))
                .frame(width: 44, height: 44)
                .background(Color(hex: "6A89CC").opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "2D3748"))
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "718096"))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
