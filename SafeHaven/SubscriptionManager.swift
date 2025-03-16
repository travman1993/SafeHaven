//
//  SubscriptionManager.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/1/25.
//
import Foundation
import StoreKit

// Add new enum to track different features
enum AppFeature {
    case emergencyContacts(count: Int)
    case journal
    case motivation
    case todoList
    case weatherInfo
    case resourceFinder
}

@MainActor
class SubscriptionManager: ObservableObject {
    @Published var isSubscribed = false
    @Published var isLoading = false
    @Published var products: [Product] = []
    @Published var purchasedProductIDs = Set<String>()
    
    // Monthly subscription product ID - configure this in App Store Connect
    private let monthlySubscriptionID = "com.safehaven.premium.monthly"
    
    // Feature restrictions for free version
    let maxEmergencyContactsFree = 1
    let journalFeatureEnabled = false
    let motivationFeatureEnabled = false
    let todoFeatureEnabled = false
    
    // Singleton instance
    static let shared = SubscriptionManager()
    
    private init() {
        // Check existing subscriptions on initialization
        Task {
            await checkSubscriptionStatus()
        }
    }
    
    // Check if a specific feature is available
    func canUseFeature(_ feature: AppFeature) -> Bool {
        if isSubscribed {
            return true
        }
        
        switch feature {
        case .emergencyContacts(let count):
            return count <= maxEmergencyContactsFree
        case .journal:
            return journalFeatureEnabled
        case .motivation:
            return motivationFeatureEnabled
        case .todoList:
            return todoFeatureEnabled
        case .weatherInfo:
            return true // Weather info available to all users
        case .resourceFinder:
            return true // Resource finder available to all users
        }
    }
    
    // Load available products from App Store
    func loadProducts() async {
        isLoading = true
        
        do {
            // Fetch products that match the subscription ID
            let storeProducts = try await Product.products(for: [monthlySubscriptionID])
            self.products = storeProducts
            self.isLoading = false
        } catch {
            print("Failed to load products: \(error)")
            self.isLoading = false
        }
    }
    
    // Purchase a subscription product
    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    // Transaction verified successfully
                    await transaction.finish()
                    
                    // Update subscription status
                    await updateCustomerProductStatus()
                    
                    return true
                case .unverified(_, _):
                    // Transaction could not be verified
                    return false
                }
            case .userCancelled:
                // User cancelled the purchase
                return false
            case .pending:
                // Purchase is pending
                return false
            @unknown default:
                return false
            }
        } catch {
            print("Purchase failed: \(error)")
            return false
        }
    }
    
    // Check and update subscription status
    private func checkSubscriptionStatus() async {
        // Remove do-catch entirely
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            
            if transaction.productID == monthlySubscriptionID &&
               transaction.expirationDate ?? .now > .now {
                isSubscribed = true
                return
            }
        }
        
        // If no active subscription found
        isSubscribed = false
    }
    
    // Update customer's product status after successful purchase
    private func updateCustomerProductStatus() async {
        // Recheck subscription status
        await checkSubscriptionStatus()
    }
    
    // Restore purchases
    func restorePurchases() async -> Bool {
        do {
            // Synchronize transactions with App Store
            try await AppStore.sync()
            
            // Recheck subscription status
            await checkSubscriptionStatus()
            
            return isSubscribed
        } catch {
            print("Error restoring purchases: \(error)")
            return false
        }
    }
    
    // Cancel subscription
    func cancelSubscription() {
        // Open App Store subscription management
        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
            UIApplication.shared.open(url)
        }
    }
}

// Extension to format product price
extension Product {
    var displayPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceFormatStyle.locale
        
        return formatter.string(from: price as NSNumber) ?? ""
    }
}
