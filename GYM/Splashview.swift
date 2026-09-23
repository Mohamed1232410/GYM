//
//  Splashview.swift
//  GYM
//
//  Created by Mohamed ahmed on 21/09/2026.
//

import SwiftUI

struct SplashView: View {
    @State private var logoScale: CGFloat = 0.4
    @State private var logoOpacity: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var taglineOpacity: Double = 0
    @State private var progressWidth: CGFloat = 0
    @State private var isFinished = false

    var body: some View {
        if isFinished {
            // Transition to main app after splash
            EmptyView()
        } else {
            ZStack {
                // Background — matches FitBody brand colors (black + purple)
                Color.black.ignoresSafeArea()

                // Subtle radial glow behind logo
                RadialGradient(
                    colors: [Color(red: 0.45, green: 0.3, blue: 0.9).opacity(0.35), .clear],
                    center: .center,
                    startRadius: 10,
                    endRadius: 280
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    // ── FitBody Logo ─────────────────────────────
                    Image("fitbody_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                        .clipShape(Circle())
                        .shadow(color: Color(red: 0.45, green: 0.3, blue: 0.9).opacity(0.6),
                                radius: 30, x: 0, y: 0)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)

                    Spacer().frame(height: 28)

                    // ── App Name ─────────────────────────────────
                    VStack(spacing: 6) {
                        HStack(spacing: 0) {
                            Text("FIT")
                                .font(.system(size: 42, weight: .black, design: .rounded))
                                .foregroundColor(Color(red: 0.88, green: 1.0, blue: 0.2)) // yellow-green
                            Text("BODY")
                                .font(.system(size: 42, weight: .light, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .opacity(titleOpacity)

                        Text("Your Complete Fitness Companion")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.55))
                            .opacity(taglineOpacity)
                    }

                    Spacer()

                    // ── Loading Bar ───────────────────────────────
                    VStack(spacing: 10) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.white.opacity(0.12))
                                    .frame(height: 3)
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color(red: 0.45, green: 0.3, blue: 0.9))
                                    .frame(width: geo.size.width * progressWidth, height: 3)
                            }
                        }
                        .frame(height: 3)
                        .padding(.horizontal, 60)

                        Text("Loading...")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.35))
                    }
                    .padding(.bottom, 60)
                }
            }
            .onAppear { startAnimations() }
        }
    }

    func startAnimations() {
        // Logo pop in
        withAnimation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.1)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        // Title fade in
        withAnimation(.easeOut(duration: 0.5).delay(0.5)) {
            titleOpacity = 1.0
        }
        // Tagline
        withAnimation(.easeOut(duration: 0.5).delay(0.75)) {
            taglineOpacity = 1.0
        }
        // Progress bar
        withAnimation(.easeInOut(duration: 1.6).delay(0.4)) {
            progressWidth = 1.0
        }
        // Dismiss after 2.4s
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            withAnimation(.easeIn(duration: 0.3)) {
                isFinished = true
            }
        }
    }
}
