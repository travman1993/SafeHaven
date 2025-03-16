//
//  PaywallView.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/1/25.
//
import SwiftUI
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
                            .foregroundColor(AppTheme.primary)
                            .padding(.top, 20)
                        
                        Text("SafeHaven Premium")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text("Unlock Full Potential")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(AppTheme.primary)
                    }
                    
                    // Feature List - Updated to highlight restricted features
                    VStack(alignment: .leading, spacing: 20) {
                        FeatureRow(
                            icon: "person.crop.circle.badge.exclamationmark",
                            title: "Unlimited Emergency Contacts",
                            description: "Add more than 1 emergency contact for better safety coverage",
                            isRestricted: true
                        )
                        
                        FeatureRow(
                            icon: "book.fill",
                            title: "Journal Feature",
                            description: "Track your thoughts, feelings, and progress with a private journal",
                            isRestricted: true
                        )
                        
                        FeatureRow(
                            icon: "checklist",
                            title: "Daily Task Management",
                            description: "Stay organized with daily to-do lists and task tracking",
                            isRestricted: true
                        )
                        
                        FeatureRow(
                            icon: "quote.bubble.fill",
                            title: "Daily Motivation",
                            description: "Get inspirational quotes to boost your mood and motivation",
                            isRestricted: true
                        )
                        
                        FeatureRow(
                            icon: "mappin.and.ellipse",
                            title: "Resource Finder",
                            description: "Find nearby shelters, food banks, and support services",
                            isRestricted: false
                        )
                        
                        FeatureRow(
                            icon: "cloud.sun.fill",
                            title: "Weather & Safety",
                            description: "Access real-time weather with safety recommendations",
                            isRestricted: false
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
                            VStack(spacing: 10) {
                                Text("Monthly Premium")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(AppTheme.textPrimary)
                                
                                Text("\(product.displayPrice) / month")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(AppTheme.primary)
                                
                                Text("Cancel anytime")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(hex: "F5F7FA"))
                                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            )
                            .padding(.horizontal)
                            
                            Button(action: {
                                purchaseSubscription(product: product)
                            }) {
                                HStack {
                                    if isProcessing {
                                        ProgressView()
                                            .padding(.trailing, 10)
                                    }
                                    
                                    Text("Subscribe Now")
                                }
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(isProcessing ? AppTheme.primary.opacity(0.7) : AppTheme.primary)
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }
                            .disabled(isProcessing)
                            
                            Button(action: {
                                restorePurchases()
                            }) {
                                Text("Restore Purchases")
                                    .font(.system(size: 16))
                                    .foregroundColor(AppTheme.primary)
                            }
                            .padding(.top, 8)
                        } else {
                            Text("Subscription unavailable")
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                    .padding(.vertical)
                    
                    // Footer
                    VStack(spacing: 10) {
                        Text("Subscribers help us continue developing and maintaining SafeHaven")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                        
                        HStack(spacing: 16) {
                            Button("Terms of Service") {
                                // Open Terms of Service
                            }
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.primary)
                            
                            Button("Privacy Policy") {
                                // Open Privacy Policy
                            }
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.primary)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationBarTitle("Premium", displayMode: .inline)
            .navigationBarItems(trailing: Button("Close") {
                dismiss()
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
            // Load products when view appears
            Task {
                await subscriptionManager.loadProducts()
            }
        }
    }
    
    private func purchaseSubscription(product: Product) {
        isProcessing = true
        
        Task {
            let success = await subscriptionManager.purchase(product)
            
            await MainActor.run {
                isProcessing = false
                
                if success {
                    alertMessage = "Thank you for subscribing to SafeHaven Premium!"
                    showAlert = true
                    
                    // Optional: Dismiss after a short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        dismiss()
                    }
                } else {
                    alertMessage = "Subscription purchase failed. Please try again."
                    showAlert = true
                }
            }
        }
    }
    
    private func restorePurchases() {
        isProcessing = true
        
        Task {
            let success = await subscriptionManager.restorePurchases()
            
            await MainActor.run {
                isProcessing = false
                
                if success {
                    alertMessage = "Your purchases have been restored."
                    showAlert = true
                    
                    // Optional: Dismiss after a short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        dismiss()
                    }
                } else {
                    alertMessage = "No purchases to restore."
                    showAlert = true
                }
            }
        }
    }
}

// Update the FeatureRow to highlight restricted features
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let isRestricted: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(isRestricted ? .white : AppTheme.primary)
                    .frame(width: 44, height: 44)
                    .background(isRestricted ? AppTheme.primary : AppTheme.primary.opacity(0.1))
                    .clipShape(Circle())
                
                if isRestricted {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.white)
                        .background(
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 18, height: 18)
                        )
                        .offset(x: 15, y: -15)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    if isRestricted {
                        Text("Premium")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AppTheme.accent)
                            .cornerRadius(4)
                    }
                }
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
