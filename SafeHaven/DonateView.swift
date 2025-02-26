import SwiftUI

struct DonateView: View {
    @State private var selectedAmount: Int? = nil
    @State private var customAmount: String = ""
    @State private var isMonthlyDonation: Bool = false

    let donationAmounts = [5, 10, 20, 50, 100]

    var body: some View {
        VStack(spacing: 20) {
            // Title & Description
            Text("Support Safe Haven")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top, 30)

            Text("Your donation helps fund the development and expansion of Safe Haven, ensuring that more people in need can access vital resources. Every contribution goes directly toward improving and growing the app.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            // Toggle: One-Time vs. Monthly Donation
            Toggle(isOn: $isMonthlyDonation) {
                Text(isMonthlyDonation ? "Monthly Donation" : "One-Time Donation")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .padding(.horizontal, 40)

            // Scrollable Preset Donation Amounts
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {  // Reduced spacing for better fit
                    ForEach(donationAmounts, id: \.self) { amount in
                        Button(action: {
                            selectedAmount = amount
                            customAmount = ""
                        }) {
                            Text("$\(amount)")
                                .font(.title2)
                                .padding()
                                .frame(width: 90)
                                .background(selectedAmount == amount ? Color.blue : Color.gray.opacity(0.3))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)
            }

            // Custom Amount Input
            TextField("Enter Custom Amount", text: $customAmount)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(.black)
                .padding(.horizontal, 40)
                .onChange(of: customAmount) {
                    selectedAmount = nil
                }

            // Spacer to push button to the bottom
            Spacer()

            // Donate Button
            Button(action: {
                print("Donate button tapped - Amount: \(selectedAmount ?? Int(customAmount) ?? 0), Recurring: \(isMonthlyDonation)")
            }) {
                Text(isMonthlyDonation ? "Donate Monthly" : "Donate Now")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 40)
            }
            .padding(.bottom, 30) // Add padding at the bottom for spacing
        }
        .frame(maxHeight: .infinity) // Make VStack take up full height
    }
}

struct DonateView_Previews: PreviewProvider {
    static var previews: some View {
        DonateView()
    }
}
