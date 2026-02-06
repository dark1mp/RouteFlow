//
//  LogoView.swift
//  RouteFlow
//
//  Created on 2026-02-06.
//

import SwiftUI

struct LogoView: View {
    var size: CGFloat = 100
    var showText: Bool = true
    
    var body: some View {
        VStack(spacing: 12) {
            // Logo Icon
            ZStack {
                // Background circle
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.2, green: 0.6, blue: 1.0),
                                Color(red: 0.1, green: 0.5, blue: 0.9)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size, height: size)
                
                VStack(spacing: 0) {
                    // Map pin (top)
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: size * 0.35))
                        .foregroundColor(.white)
                    
                    // Route line (middle)
                    VStack(spacing: 2) {
                        Capsule()
                            .fill(.white.opacity(0.8))
                            .frame(width: size * 0.45, height: 2)
                        
                        HStack(spacing: 4) {
                            Capsule()
                                .fill(.white.opacity(0.8))
                                .frame(width: size * 0.2, height: 2)
                            
                            Circle()
                                .fill(.white)
                                .frame(width: 4, height: 4)
                            
                            Capsule()
                                .fill(.white.opacity(0.8))
                                .frame(width: size * 0.15, height: 2)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    // Delivery box (bottom)
                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: size * 0.25))
                        .foregroundColor(.white)
                }
            }
            
            // App name
            if showText {
                VStack(spacing: 2) {
                    Text("RouteFlow")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Smart Delivery Route Planning")
                        .font(.system(size: 12, weight: .medium, design: .default))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// Compact version for app icon
struct LogoIconView: View {
    var size: CGFloat = 100
    
    var body: some View {
        ZStack {
            // Background circle with gradient
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.2, green: 0.6, blue: 1.0),
                            Color(red: 0.1, green: 0.5, blue: 0.9)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 0) {
                // Map pin
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: size * 0.35))
                    .foregroundColor(.white)
                
                // Route line with dots
                VStack(spacing: 3) {
                    Capsule()
                        .fill(.white.opacity(0.9))
                        .frame(width: size * 0.4, height: 2)
                    
                    HStack(spacing: 3) {
                        Circle()
                            .fill(.white)
                            .frame(width: 3, height: 3)
                        
                        Capsule()
                            .fill(.white.opacity(0.7))
                            .frame(width: size * 0.2, height: 1.5)
                    }
                }
                .padding(.vertical, 3)
                
                // Delivery box
                Image(systemName: "shippingbox.fill")
                    .font(.system(size: size * 0.25))
                    .foregroundColor(.white)
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    VStack(spacing: 40) {
        LogoView(size: 120, showText: true)
        
        Divider()
        
        HStack(spacing: 30) {
            LogoIconView(size: 80)
            LogoIconView(size: 100)
            LogoIconView(size: 120)
        }
    }
    .padding()
}
