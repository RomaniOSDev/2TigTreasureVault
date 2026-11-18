//
//  FlameView.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

struct FlameShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + h * 0.68),
            control1: CGPoint(x: rect.midX + w * 0.1, y: rect.minY + h * 0.25),
            control2: CGPoint(x: rect.maxX, y: rect.minY + h * 0.42)
        )
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY),
            control1: CGPoint(x: rect.maxX, y: rect.minY + h * 0.88),
            control2: CGPoint(x: rect.midX + w * 0.3, y: rect.maxY)
        )
        path.addCurve(
            to: CGPoint(x: rect.minX, y: rect.minY + h * 0.68),
            control1: CGPoint(x: rect.midX - w * 0.3, y: rect.maxY),
            control2: CGPoint(x: rect.minX, y: rect.minY + h * 0.88)
        )
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.minY),
            control1: CGPoint(x: rect.minX, y: rect.minY + h * 0.42),
            control2: CGPoint(x: rect.midX - w * 0.1, y: rect.minY + h * 0.25)
        )
        path.closeSubpath()
        return path
    }
}

/// A two-layer flame with a gentle flicker. Holds still when Reduce Motion is on.
struct FlameView: View {
    @State private var flicker = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            FlameShape()
                .fill(
                    LinearGradient(
                        colors: [VaultPalette.emberDeep, VaultPalette.ember],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            FlameShape()
                .fill(
                    LinearGradient(
                        colors: [VaultPalette.gold, VaultPalette.goldLight],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .scaleEffect(0.55, anchor: .bottom)
        }
        .scaleEffect(x: flicker ? 0.9 : 1.04, y: flicker ? 1.08 : 0.95, anchor: .bottom)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 0.42).repeatForever(autoreverses: true)) {
                flicker = true
            }
        }
    }
}

#Preview {
    FlameView()
        .frame(width: 80, height: 110)
        .padding()
        .background(VaultPalette.caveDeep)
}
