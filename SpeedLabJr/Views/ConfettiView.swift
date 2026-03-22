// ConfettiView.swift
// SpeedLabJr

import SwiftUI

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var speed: CGFloat
    var rotation: Double
    var color: Color
    var scale: CGFloat
    var shapeType: Int
}

struct ConfettiView: View {
    let isFiring: Bool
    
    @State private var particles: [ConfettiParticle] = []
    @State private var timer: Timer?
    
    let colors: [Color] = [.orange, .blue, .green, .yellow, .pink, .purple]
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    Group {
                        if particle.shapeType == 0 {
                            Circle().fill(particle.color)
                        } else if particle.shapeType == 1 {
                            Rectangle().fill(particle.color)
                        } else {
                            RoundedRectangle(cornerRadius: 2).fill(particle.color)
                        }
                    }
                    .frame(width: 8 * particle.scale, height: 8 * particle.scale)
                    .rotationEffect(.degrees(particle.rotation))
                    .position(x: particle.x, y: particle.y)
                }
            }
            .onChange(of: isFiring) { _, firing in
                if firing {
                    fireConfetti(in: geo.size)
                } else {
                    particles.removeAll()
                    timer?.invalidate()
                }
            }
        }
        .allowsHitTesting(false)
    }
    
    private func fireConfetti(in size: CGSize) {
        particles = (0..<80).map { _ in
            ConfettiParticle(
                x: size.width / 2 + CGFloat.random(in: -30...30), // Start from center top
                y: -50,
                speed: CGFloat.random(in: 10...30),
                rotation: Double.random(in: 0...360),
                color: colors.randomElement()!,
                scale: CGFloat.random(in: 0.8...1.5),
                shapeType: Int.random(in: 0...2)
            )
        }
        
        // Spread the initial burst
        for i in 0..<particles.count {
            particles[i].x += CGFloat.random(in: -size.width/2...size.width/2)
        }
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            var activeCount = 0
            for i in 0..<particles.count {
                particles[i].y += particles[i].speed
                particles[i].x += CGFloat.random(in: -5...5) // flutter
                particles[i].rotation += CGFloat.random(in: -15...15)
                if particles[i].y < size.height + 100 {
                    activeCount += 1
                }
            }
            if activeCount == 0 {
                timer?.invalidate()
            }
        }
    }
}
