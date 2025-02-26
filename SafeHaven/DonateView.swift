import SwiftUI

struct DonateView: View {
    @State private var selectedAmount: Int? = nil
    @State private var customAmount: String = ""
    @State private var isMonthlyDonation: Bool = false
    @State private var showingThankYouAlert = false
    @State private var donorName: String = ""
    @State private var donorEmail: String = ""
    @State private var showingPaymentSheet = false
    
    let donationAmounts = [5, 10, 20, 50, 100]
    
    var donationAmount: Double {
        if let selected = selectedAmount {
            return Double(selected)
        } else if let custom = Double(customAmount), custom > 0 {
            return custom
        }
        return 0
    }
    
    var isValidDonation: Bool {
        donationAmount > 0
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header Section
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "E8505B"), Color(hex: "F47C7C")]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "heart.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 20)
                    
                    Text("Make a Difference")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "2D3748"))
                    
                    Text("Your support helps us improve Safe Haven and reach more people in need")
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
                
                // Donation Type Selection
                VStack(alignment: .leading, spacing: 16) {
                    Text("Select Donation Type")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "2D3748"))
                    
                    HStack(spacing: 12) {
                        // One-time button
                        Button(action: {
                            isMonthlyDonation = false
                        }) {
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .stroke(isMonthlyDonation ? Color.gray.opacity(0.3) : Color(hex: "6A89CC"), lineWidth: 2)
                                        .frame(width: 24, height: 24)
                                    
                                    if !isMonthlyDonation {
                                        Circle()
                                            .fill(Color(hex: "6A89CC"))
                                            .frame(width: 16, height: 16)
                                    }
                                }
                                
                                Text("One-time")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(isMonthlyDonation ? Color(hex: "718096") : Color(hex: "2D3748"))
                                
                                Image(systemName: "creditcard.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(isMonthlyDonation ? Color.gray.opacity(0.5) : Color(hex: "6A89CC"))
                                    .padding(.top, 4)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(isMonthlyDonation ? Color.white : Color(hex: "6A89CC").opacity(0.1))
                                    .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
                            )
                        }
                        
                        // Monthly button
                        Button(action: {
                            isMonthlyDonation = true
                        }) {
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .stroke(isMonthlyDonation ? Color(hex: "E8505B") : Color.gray.opacity(0.3), lineWidth: 2)
                                        .frame(width: 24, height: 24)
                                    
                                    if isMonthlyDonation {
                                        Circle()
                                            .fill(Color(hex: "E8505B"))
                                            .frame(width: 16, height: 16)
                                    }
                                }
                                
                                Text("Monthly")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(isMonthlyDonation ? Color(hex: "2D3748") : Color(hex: "718096"))
                                
                                Image(systemName: "calendar.badge.clock")
                                    .font(.system(size: 24))
                                    .foregroundColor(isMonthlyDonation ? Color(hex: "E8505B") : Color.gray.opacity(0.5))
                                    .padding(.top, 4)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(isMonthlyDonation ? Color(hex: "E8505B").opacity(0.1) : Color.white)
                                    .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
                            )
                        }
                    }
                    
                    // Impact info
                    VStack(spacing: 16) {
                        Text("Your Impact")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "2D3748"))
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        HStack(spacing: 20) {
                            ImpactItem(
                                icon: "house.fill",
                                title: "Shelters",
                                description: "Support emergency housing"
                            )
                            
                            ImpactItem(
                                icon: "cross.case.fill",
                                title: "Healthcare",
                                description: "Fund medical services"
                            )
                            
                            ImpactItem(
                                icon: "book.fill",
                                title: "Education",
                                description: "Enable learning resources"
                            )
                        }
                    }
                    .padding(.vertical, 12)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal)
                
                // Amount Selection
                VStack(alignment: .leading, spacing: 20) {
                    Text("Choose Amount")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "2D3748"))
                    
                    // Amount Display
                    Text(donationAmount > 0 ? "$\(String(format: "%.2f", donationAmount))" : "Select an amount")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(donationAmount > 0 ? Color(hex: "6A89CC") : Color.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 8)
                    
                    // Preset amounts
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(donationAmounts, id: \.self) { amount in
                            Button(action: {
                                selectedAmount = amount
                                customAmount = ""
                            }) {
                                Text("$\(amount)")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(selectedAmount == amount ? .white : Color(hex: "6A89CC"))
                                    .frame(height: 50)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedAmount == amount ? Color(hex: "6A89CC") : Color(hex: "6A89CC").opacity(0.1))
                                    )
                            }
                        }
                    }
                    
                    // Custom amount
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Custom Amount")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "718096"))
                        
                        HStack {
                            Text("$")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color(hex: "2D3748"))
                            
                            TextField("Enter amount", text: $customAmount)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 18))
                                .onChange(of: customAmount) { oldValue, newValue in
                                    selectedAmount = nil
                                }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(customAmount.isEmpty ? Color.gray.opacity(0.3) : Color(hex: "6A89CC"), lineWidth: 1)
                        )
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal)
                
                // Donation Button
                Button(action: {
                    showingPaymentSheet = true
                }) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 18))
                        
                        Text(isMonthlyDonation ? "Donate Monthly" : "Donate Now")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isValidDonation ?
                                  (isMonthlyDonation ? Color(hex: "E8505B") : Color(hex: "41B3A3")) :
                                    Color.gray.opacity(0.3))
                    )
                    .foregroundColor(.white)
                    .padding(.horizontal)
                }
                .disabled(!isValidDonation)
                .padding(.vertical, 10)
                
                // Security and trust badges
                VStack(spacing: 16) {
                    HStack(spacing: 24) {
                        SecurityBadge(icon: "lock.fill", text: "Secure")
                        SecurityBadge(icon: "checkmark.shield.fill", text: "Encrypted")
                        SecurityBadge(icon: "creditcard.fill", text: "PCI Compliant")
                    }
                    
                    Text("100% of your donation goes directly to our mission")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "718096"))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 30)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal)
                
                // Donor Information
                VStack(alignment: .leading, spacing: 20) {
                    Text("Your Information")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "2D3748"))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name (Optional)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "718096"))
                        
                        TextField("Your name", text: $donorName)
                            .font(.system(size: 16))
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email (Optional)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "718096"))
                        
                        TextField("Your email", text: $donorEmail)
                            .font(.system(size: 16))
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                }
            }
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

struct SecurityBadge: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "41B3A3"))
            
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "2D3748"))
        }
    }
}
