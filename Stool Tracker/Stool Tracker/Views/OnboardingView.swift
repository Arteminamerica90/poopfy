//
//  OnboardingView.swift
//  Stool Tracker
//
//  Created by Artem Menshikov on 02.01.2026.
//

import SwiftUI

struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
}

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome to Stool Tracker",
            description: "Track your bowel movements easily and monitor your digestive health with detailed statistics and insights.",
            imageName: "heart.fill"
        ),
        OnboardingPage(
            title: "Quick Entry",
            description: "Tap the + button or any day on the calendar to quickly add a new entry. Record Bristol type, color, volume, and symptoms.",
            imageName: "plus.circle.fill"
        ),
        OnboardingPage(
            title: "Calendar View",
            description: "See all your entries at a glance. Each day shows the Bristol type number in a colored circle representing the stool color.",
            imageName: "calendar"
        ),
        OnboardingPage(
            title: "Statistics",
            description: "View detailed statistics including frequency, type distribution, color analysis, and track patterns over time.",
            imageName: "chart.bar.fill"
        ),
        OnboardingPage(
            title: "Educational Articles",
            description: "Learn about digestive health, nutrition, and foods that support healthy bowel movements with our curated articles.",
            imageName: "book.fill"
        ),
        OnboardingPage(
            title: "Privacy First",
            description: "All your data is stored locally on your device. Your health information never leaves your phone.",
            imageName: "lock.shield.fill"
        )
    ]
    
    var body: some View {
        ZStack {
            AppTheme.gradientBackground
                .ignoresSafeAreaCompat()
            
            VStack(spacing: 0) {
                // Page content
                onboardingTabView
                
                // Navigation buttons
                HStack(spacing: 16) {
                    if currentPage > 0 {
                        Button(action: {
                            withAnimation {
                                currentPage -= 1
                            }
                        }) {
                            Text("Previous")
                                .font(.headline)
                                .foregroundColor(AppTheme.darkAccentColor)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(25)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if currentPage < pages.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            completeOnboarding()
                        }
                    }) {
                        Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(AppTheme.darkAccentColor)
                            .cornerRadius(25)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
    
    @ViewBuilder
    private var onboardingTabView: some View {
        if #available(iOS 14.0, *) {
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        } else {
            // iOS 13 fallback - use GeometryReader with HStack for page-like navigation
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .frame(width: geometry.size.width)
                    }
                }
                .offset(x: -CGFloat(currentPage) * geometry.size.width)
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            let threshold: CGFloat = 50
                            if value.translation.width > threshold && currentPage > 0 {
                                withAnimation {
                                    currentPage -= 1
                                }
                            } else if value.translation.width < -threshold && currentPage < pages.count - 1 {
                                withAnimation {
                                    currentPage += 1
                                }
                            }
                        }
                )
            }
        }
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        withAnimation {
            isPresented = false
        }
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon
            Image(systemName: page.imageName)
                .font(.system(size: 80))
                .foregroundColor(AppTheme.darkAccentColor)
                .padding(.bottom, 20)
            
            // Title
            Text(page.title)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            // Description
            Text(page.description)
                .font(.system(size: 18))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 32)
            
            Spacer()
        }
    }
}

// Helper to check if onboarding is needed
extension UserDefaults {
    static var hasCompletedOnboarding: Bool {
        get {
            UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "hasCompletedOnboarding")
        }
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
}

