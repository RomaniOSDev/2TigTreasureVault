//
//  GuardianStatueArt.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

/// Stone warrior with a spear and a shield.
struct GuardianStatueArt: View {
    var body: some View {
        Canvas { context, size in
            let a = ArtSpace(size: size)
            let stoneFill = a.vertical([VaultPalette.stoneLight, VaultPalette.stone], from: 0.1, to: 0.9)

            context.fill(a.ellipse(0.12, 0.86, 0.76, 0.1), with: .color(.black.opacity(0.35)))

            // Spear behind the body.
            context.stroke(
                a.line([(0.77, 0.12), (0.77, 0.88)]),
                with: .color(VaultPalette.stoneDark),
                style: StrokeStyle(lineWidth: a.u(0.035), lineCap: .round)
            )
            context.fill(
                a.polygon([(0.77, 0.03), (0.82, 0.15), (0.72, 0.15)]),
                with: .color(VaultPalette.stoneLight)
            )

            context.fill(a.rounded(0.2, 0.86, 0.6, 0.09, radius: 0.02), with: .color(VaultPalette.stoneDark))

            // Robe and shoulders.
            context.fill(a.polygon([(0.35, 0.87), (0.65, 0.87), (0.62, 0.44), (0.38, 0.44)]), with: stoneFill)
            context.fill(a.rounded(0.29, 0.4, 0.42, 0.13, radius: 0.05), with: stoneFill)
            context.stroke(
                a.line([(0.5, 0.74), (0.5, 0.87)]),
                with: .color(VaultPalette.stoneDark.opacity(0.7)),
                lineWidth: a.u(0.012)
            )

            // Head and helmet.
            context.fill(a.ellipse(0.4, 0.2, 0.2, 0.23), with: stoneFill)
            context.fill(
                a.polygon([(0.37, 0.31), (0.63, 0.31), (0.61, 0.2), (0.5, 0.12), (0.39, 0.2)]),
                with: .color(VaultPalette.stone)
            )
            context.fill(a.polygon([(0.47, 0.13), (0.5, 0.04), (0.53, 0.13)]), with: .color(VaultPalette.stoneLight))
            context.fill(a.rounded(0.43, 0.3, 0.14, 0.03, radius: 0.01), with: .color(VaultPalette.safety))

            // Shield.
            var shield = Path()
            shield.move(to: a.p(0.35, 0.5))
            shield.addLine(to: a.p(0.65, 0.5))
            shield.addCurve(to: a.p(0.5, 0.83), control1: a.p(0.65, 0.7), control2: a.p(0.57, 0.79))
            shield.addCurve(to: a.p(0.35, 0.5), control1: a.p(0.43, 0.79), control2: a.p(0.35, 0.7))
            shield.closeSubpath()
            context.fill(shield, with: a.vertical([VaultPalette.stoneLight, VaultPalette.stoneDark], from: 0.5, to: 0.85))
            context.stroke(shield, with: .color(VaultPalette.stoneDark), lineWidth: a.u(0.014))
            context.fill(
                a.polygon([(0.5, 0.56), (0.555, 0.64), (0.5, 0.73), (0.445, 0.64)]),
                with: .color(VaultPalette.gold)
            )
        }
    }
}

#Preview {
    GuardianStatueArt()
        .frame(width: 160, height: 160)
        .padding()
        .background(VaultPalette.caveShadow)
}
