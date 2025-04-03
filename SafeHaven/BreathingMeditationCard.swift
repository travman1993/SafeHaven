//
//  BreathingMeditationCard.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 4/3/25.
//
import SwiftUI

// MARK: - Breathing & Meditation Card
struct BreathingMeditationCard: View {
    @State private var showingBreathingView = false
    
    var body: some View {
        Button(action: {
            showingBreathingView = true
        }) {
            VStack(alignment: .leading, spacing: ResponsiveLayout.padding(12)) {
                HStack {
                    Image(systemName: "lungs.fill")
                        .font(.system(size: ResponsiveLayout.fontSize(24)))
                        .foregroundColor(AppTheme.secondary)
                    
                    Text("Mental Wellness Tools")
                        .font(.system(size: ResponsiveLayout.fontSize(18), weight: .semibold))
                        .foregroundColor(AppTheme.adaptiveTextPrimary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(AppTheme.adaptiveTextSecondary)
                }
                
                Text("Offer calm and care during difficult moments — fully offline")
                    .font(.system(size: ResponsiveLayout.fontSize(14)))
                    .foregroundColor(AppTheme.adaptiveTextSecondary)
                    .padding(.top, 2)
                
                HStack(spacing: ResponsiveLayout.padding(12)) {
                    Feature(icon: "wind", text: "Breathing Exercises")
                    Feature(icon: "brain.head.profile", text: "Guided Meditations")
                    Feature(icon: "note.text", text: "Mood Journal")
                }
                .padding(.top, 8)
            }
            .padding(ResponsiveLayout.padding())
            .background(AppTheme.adaptiveCardBackground)
            .cornerRadius(ResponsiveLayout.isIPad ? 20 : 16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        }
        .sheet(isPresented: $showingBreathingView) {
            BreathingExerciseView()
        }
    }
    
    private struct Feature: View {
        let icon: String
        let text: String
        
        var body: some View {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: ResponsiveLayout.fontSize(12)))
                    .foregroundColor(AppTheme.secondary)
                
                Text(text)
                    .font(.system(size: ResponsiveLayout.fontSize(12)))
                    .foregroundColor(AppTheme.adaptiveTextSecondary)
            }
        }
    }
}

// Breathing Exercise View
struct BreathingExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedExercise = "Calm Down"
    @State private var isBreathingActive = false
    @State private var breathPhase: BreathPhase = .inhale
    @State private var progress: CGFloat = 0
    
    enum BreathPhase {
        case inhale, hold, exhale, rest
    }
    
    let exercises = ["Calm Down", "Fall Asleep", "Ease Anxiety"]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "43AA8B").opacity(0.6),
                    Color(hex: "90BE6D").opacity(0.4)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: ResponsiveLayout.padding(24)) {
                // Close button
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: ResponsiveLayout.fontSize(24)))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                if !isBreathingActive {
                    // Exercise selection
                    VStack(spacing: ResponsiveLayout.padding(40)) {
                        Text("Breathing Exercises")
                            .font(.system(size: ResponsiveLayout.fontSize(28), weight: .bold))
                            .foregroundColor(.white)
                        
                        VStack(spacing: ResponsiveLayout.padding(16)) {
                            ForEach(exercises, id: \.self) { exercise in
                                Button(action: {
                                    selectedExercise = exercise
                                }) {
                                    HStack {
                                        Text(exercise)
                                            .font(.system(size: ResponsiveLayout.fontSize(18), weight: .medium))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        if selectedExercise == exercise {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white.opacity(selectedExercise == exercise ? 0.3 : 0.1))
                                    )
                                }
                            }
                        }
                        
                        Button(action: {
                            withAnimation {
                                isBreathingActive = true
                                startBreathingExercise()
                            }
                        }) {
                            Text("Begin")
                                .font(.system(size: ResponsiveLayout.fontSize(18), weight: .bold))
                                .foregroundColor(Color(hex: "43AA8B"))
                                .padding(.vertical, ResponsiveLayout.padding(16))
                                .padding(.horizontal, ResponsiveLayout.padding(40))
                                .background(
                                    Capsule()
                                        .fill(Color.white)
                                )
                                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        }
                    }
                    .padding()
                } else {
                    // Active breathing exercise
                    VStack(spacing: ResponsiveLayout.padding(30)) {
                        Text(selectedExercise)
                            .font(.system(size: ResponsiveLayout.fontSize(24), weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(breathPhaseInstruction)
                            .font(.system(size: ResponsiveLayout.fontSize(20), weight: .medium))
                            .foregroundColor(.white)
                            .animation(.easeInOut, value: breathPhase)
                        
                        // Breathing circle
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 2)
                                .frame(width: 200, height: 200)
                            
                            Circle()
                                .scale(breathingScale)
                                .fill(Color.white.opacity(0.3))
                                .frame(width: 200, height: 200)
                                .animation(.easeInOut(duration: breathPhaseDuration), value: breathPhase)
                            
                            Text(breathPhaseCountdown)
                                .font(.system(size: ResponsiveLayout.fontSize(40), weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Button(action: {
                            withAnimation {
                                isBreathingActive = false
                            }
                        }) {
                            Text("End Session")
                                .font(.system(size: ResponsiveLayout.fontSize(16), weight: .medium))
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 24)
                                .background(
                                    Capsule()
                                        .stroke(Color.white, lineWidth: 1)
                                )
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    private var breathPhaseInstruction: String {
        switch breathPhase {
        case .inhale: return "Breathe In"
        case .hold: return "Hold"
        case .exhale: return "Breathe Out"
        case .rest: return "Rest"
        }
    }
    
    private var breathPhaseCountdown: String {
        return "\(Int(ceil(breathPhaseDuration * (1 - progress))))"
    }
    
    private var breathPhaseDuration: Double {
        switch breathPhase {
        case .inhale: return 4.0
        case .hold: return 2.0
        case .exhale: return 6.0
        case .rest: return 2.0
        }
    }
    
    private var breathingScale: CGFloat {
        switch breathPhase {
        case .inhale: return 1.0
        case .hold: return 1.0
        case .exhale: return 0.7
        case .rest: return 0.7
        }
    }
    
    private func startBreathingExercise() {
        progress = 0
        breathPhase = .inhale
        animateBreathPhase()
    }
    
    private func animateBreathPhase() {
        withAnimation(.linear(duration: breathPhaseDuration)) {
            progress = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + breathPhaseDuration) {
            if isBreathingActive {
                progress = 0
                
                switch breathPhase {
                case .inhale: breathPhase = .hold
                case .hold: breathPhase = .exhale
                case .exhale: breathPhase = .rest
                case .rest: breathPhase = .inhale
                }
                
                animateBreathPhase()
            }
        }
    }
}
