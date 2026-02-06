//
//  LaunchScreenView.swift
//  RouteFlow
//
//  Created on 2026-02-06.
//

import SwiftUI

struct LaunchScreenView: View {
    @State private var isActive = false
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.97, blue: 1.0),
                    Color(red: 0.9, green: 0.95, blue: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                // Logo with animation
                VStack(spacing: 0) {
                    LogoIconView(size: 140)
                        .scaleEffect(scale)
                        .opacity(opacity)
                }
                
                // Loading indicator
                VStack(spacing: 12) {
                    ProgressView()
                        .tint(Color(red: 0.2, green: 0.6, blue: 1.0))
                        .scaleEffect(1.2, anchor: .center)
                    
                    Text("Initializing RouteFlow...")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .opacity(opacity)
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
            
            // Dismiss splash screen after 1.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeIn(duration: 0.3)) {
                    isActive = true
                }
            }
        }
    }
}

#Preview {
    LaunchScreenView()
}
