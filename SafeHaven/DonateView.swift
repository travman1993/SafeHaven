import SwiftUI
import StoreKit

// Simple product model to represent in-app purchases
struct SupportProduct: Identifiable {
    let id: String // This matches the product ID in App Store Connect
    let amount: Int
    let displayName: String
}

// Making StoreManager conform to @unchecked Sendable
@MainActor
class StoreManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchasedProductIDs = Set<String>()
    @Published var isLoading = false
    
    // Add product IDs here that match your App Store Connect configuration
    // Format typically: com.yourcompany.yourapp.support.amount
    private let supportProductIDs = [
        "com.rodriguez.travis.safehaven.support.tier1",
        "com.rodriguez.travis.safehaven.support.tier2",
        "com.rodriguez.travis.safehaven.support.tier3",
        "com.rodriguez.travis.safehaven.support.tier4",
        "com.rodriguez.travis.safehaven.support.tier5"
    ]
    
    func requestProducts() {
        isLoading = true
        Task {
            do {
                // Request the products from the App Store
                let storeProducts = try await Product.products(for: supportProductIDs)
                self.products = storeProducts
                self.isLoading = false
            } catch {
                print("Failed to load products: \(error)")
                self.isLoading = false
            }
        }
    }
    
    func purchase(_ product: Product) {
        Task {
            do {
                let result = try await product.purchase()
                
                switch result {
                case .success(let verification):
                    // Check whether the transaction is verified
                    switch verification {
                    case .verified(let transaction):
                        // Successful purchase
                        await transaction.finish()
                        self.purchasedProductIDs.insert(product.id)
                    case .unverified:
                        // Transaction can't be verified
                        break
                    }
                case .userCancelled:
                    break
                case .pending:
                    break
                @unknown default:
                    break
                }
            } catch {
                print("Purchase failed: \(error)")
            }
        }
    }
}

struct DonateView: View {
    @StateObject private var storeManager = StoreManager()
    @State private var showingThankYouAlert = false
    @State private var selectedProduct: Product?
    @State private var showingMonthlyOptions = false
    
    // Fixed support tiers that will match your StoreKit products
    let supportTiers = [5, 10, 20, 50, 100]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header Section
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "6A89CC"), Color(hex: "41B3A3")]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "heart.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 20)
                    
                    Text("Support SafeHaven")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "2D3748"))
                    
                    Text("Your support helps us improve SafeHaven and develop new features to assist more people in need")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "718096"))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 20)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal)
                
                // Support Type Selection
                VStack(alignment: .leading, spacing: 16) {
                    Text("How Your Support Helps")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "2D3748"))
                    
                    // Impact info
                    VStack(spacing: 16) {
                        HStack(spacing: 20) {
                            ImpactItem(
                                icon: "hammer.fill",
                                title: "Development",
                                description: "Fund new features and improvements"
                            )
                            
                            ImpactItem(
                                icon: "map.fill",
                                title: "Resources",
                                description: "Expand our resource database"
                            )
                            
                            ImpactItem(
                                icon: "server.rack",
                                title: "Infrastructure",
                                description: "Support app hosting and services"
                            )
                        }
                        
                        if showingMonthlyOptions {
                            Text("Monthly support helps us plan long-term features and sustainability")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "718096"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        } else {
                            Text("One-time support helps us address immediate development needs")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "718096"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 12)
                    
                    // Toggle between one-time and monthly
                    Picker("Support Type", selection: $showingMonthlyOptions) {
                        Text("One-time").tag(false)
                        Text("Monthly").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.vertical, 8)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal)
                
                // Support Options
                VStack(alignment: .leading, spacing: 20) {
                    Text("Choose Amount")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "2D3748"))
                    
                    if storeManager.isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                                .padding()
                            Spacer()
                        }
                    } else if storeManager.products.isEmpty {
                        VStack {
                            Text("Support options are currently unavailable")
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "718096"))
                                .multilineTextAlignment(.center)
                                .padding()
                            
                            Button(action: {
                                storeManager.requestProducts()
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
                        .frame(maxWidth: .infinity)
                    } else {
                        // Support amount options
                        let filteredProducts = storeManager.products.filter { product in
                            // Filter based on whether it's a subscription or one-time purchase
                            let isSubscription = product.type == .autoRenewable
                            return isSubscription == showingMonthlyOptions
                        }
                        
                        if !filteredProducts.isEmpty {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(filteredProducts, id: \.id) { product in
                                    Button(action: {
                                        selectedProduct = product
                                    }) {
                                        VStack(spacing: 8) {
                                            Text(product.displayName)
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(selectedProduct?.id == product.id ? .white : Color(hex: "2D3748"))
                                            
                                            Text(product.displayPrice)
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(selectedProduct?.id == product.id ? .white : Color(hex: "6A89CC"))
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(selectedProduct?.id == product.id ? Color(hex: "6A89CC") : Color(hex: "F5F7FA"))
                                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                        )
                                    }
                                }
                            }
                        } else {
                            Text("No \(showingMonthlyOptions ? "monthly" : "one-time") support options are currently available")
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "718096"))
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal)
                
                // Support Button
                Button(action: {
                    if let product = selectedProduct {
                        storeManager.purchase(product)
                        showingThankYouAlert = true
                    }
                }) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 18))
                        
                        Text(showingMonthlyOptions ? "Support Monthly" : "Support Now")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(selectedProduct != nil ?
                                  (showingMonthlyOptions ? Color(hex: "6A89CC") : Color(hex: "41B3A3")) :
                                    Color.gray.opacity(0.3))
                    )
                    .foregroundColor(.white)
                    .padding(.horizontal)
                }
                .disabled(selectedProduct == nil)
                .padding(.vertical, 10)
                
                // Future vision
                VStack(spacing: 16) {
                    Text("Our Vision")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "2D3748"))
                    
                    Text("With enough support, we aim to expand SafeHaven beyond an informational tool to provide direct assistance to those in need. Your contribution today helps us build this future.")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "718096"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    NavigationLink(destination: DeveloperStoryView()) {
                        HStack {
                            Image(systemName: "person.fill")
                                .font(.system(size: 14))
                            Text("Meet the Developer")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(Color(hex: "6A89CC"))
                        .padding(.vertical, 8)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            storeManager.requestProducts()
        }
        .navigationTitle("Support Our Mission")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showingThankYouAlert) {
            Alert(
                title: Text("Thank You!"),
                message: Text("Your support helps us continue to develop SafeHaven and work toward our mission of helping those in need."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct ImpactItem: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Color(hex: "6A89CC"))
                .frame(width: 50, height: 50)
                .background(Color(hex: "6A89CC").opacity(0.1))
                .clipShape(Circle())
            
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "2D3748"))
            
            Text(description)
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "718096"))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
    }
}
