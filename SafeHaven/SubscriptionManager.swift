//
//  SubscriptionManager.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/1/25.
//
import SwiftUI
import StoreKit

class SubscriptionManager: ObservableObject {
    @Published var isSubscribed = false
    @Published var isLoading = false
    @Published var products: [Product] = []
    @Published var purchasedProductIDs = Set<String>()
    
    // Monthly subscription product ID - configure this in App Store Connect
    private let monthlySubscriptionID = "com.rodriguez.travis.safehaven.subscription.monthly"
    
    static let shared = SubscriptionManager()
    
    private init() {
        // For now, just set to false by default
        isSubscribed = false
        
        // Request products
        Task {
            await loadProducts()
        }
    }
    
    @MainActor
    func loadProducts() async {
        isLoading = true
        
        do {
            let storeProducts = try await Product.products(for: [monthlySubscriptionID])
            self.products = storeProducts
            self.isLoading = false
        } catch {
            print("Failed to load products: \(error)")
            self.isLoading = false
        }
    }
    
    // Simplified purchase method to avoid type issues
    @MainActor
    func purchase(_ product: Product) async -> Bool {
        do {
            // Try to purchase the product
            let result = try await product.purchase()
            
            // Process the result
            if case .success = result {
                // Mark as subscribed without complex verification for now
                self.isSubscribed = true
                self.purchasedProductIDs.insert(product.id)
                return true
            } else {
                return false
            }
        } catch {
            print("Purchase failed: \(error)")
            return false
        }
    }
    
    // Debug helpers
    func debugSetSubscribed(_ value: Bool) {
        isSubscribed = value
    }
}

// Extension for product price formatting
extension Product {
    var displayPrice: String {
        return self.price.formatted(.currency(code: self.priceFormatStyle.locale.currency?.identifier ?? "USD"))
    }
}
