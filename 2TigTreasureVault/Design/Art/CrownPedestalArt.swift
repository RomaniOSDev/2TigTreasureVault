//
//  CrownPedestalArt.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

/// A jeweled crown resting on a velvet cushion atop a marble column.
struct CrownPedestalArt: View {
    var body: some View {
        Canvas { context, size in
            let a = ArtSpace(size: size)

            context.fill(
                a.circle(0.5, 0.32, radius: 0.5),
                with: a.radial([VaultPalette.goldLight.opacity(0.42), .clear], cx: 0.5, cy: 0.32, radius: 0.5)
            )
            context.fill(a.ellipse(0.14, 0.86, 0.72, 0.1), with: .color(.black.opacity(0.35)))

            // Column.
            context.fill(a.rounded(0.24, 0.86, 0.52, 0.09, radius: 0.02), with: .color(VaultPalette.stoneDark))
            context.fill(
                a.box(0.33, 0.6, 0.34, 0.27),
                with: a.horizontal([VaultPalette.stone, VaultPalette.stoneLight, VaultPalette.stone], from: 0.33, to: 0.67)
            )
            let flutes: [CGFloat] = [0.41, 0.5, 0.59]
            for x in flutes {
                context.stroke(
                    a.line([(x, 0.63), (x, 0.85)]),
                    with: .color(VaultPalette.stoneDark.opacity(0.5)),
                    lineWidth: a.u(0.01)
                )
            }
            context.fill(a.rounded(0.27, 0.55, 0.46, 0.07, radius: 0.02), with: .color(VaultPalette.stoneLight))

            // Cushion.
            context.fill(
                a.rounded(0.28, 0.43, 0.44, 0.14, radius: 0.06),
                with: a.vertical([ArtColor.crimson, ArtColor.crimsonDark], from: 0.43, to: 0.57)
            )
            context.fill(a.circle(0.28, 0.5, radius: 0.022), with: .color(VaultPalette.gold))
            context.fill(a.circle(0.72, 0.5, radius: 0.022), with: .color(VaultPalette.gold))

            // Crown.
            let goldFill = a.vertical([VaultPalette.goldLight, VaultPalette.gold, VaultPalette.goldDeep], from: 0.1, to: 0.46)
            let points = a.polygon([
                (0.32, 0.38), (0.3, 0.17), (0.41, 0.28), (0.5, 0.1), (0.59, 0.28), (0.7, 0.17), (0.68, 0.38)
            ])
            context.fill(points, with: goldFill)
            context.stroke(points, with: .color(VaultPalette.goldDeep), lineWidth: a.u(0.012))
            context.fill(a.rounded(0.31, 0.36, 0.38, 0.09, radius: 0.02), with: goldFill)
            context.stroke(
                a.rounded(0.31, 0.36, 0.38, 0.09, radius: 0.02),
                with: .color(VaultPalette.goldDeep),
                lineWidth: a.u(0.012)
            )

            let tipGems: [(x: CGFloat, y: CGFloat, light: Color, dark: Color)] = [
                (0.3, 0.165, ArtColor.sapphire, ArtColor.sapphireDark),
                (0.5, 0.095, ArtColor.ruby, ArtColor.rubyDark),
                (0.7, 0.165, ArtColor.sapphire, ArtColor.sapphireDark),
                (0.4, 0.405, ArtColor.emerald, ArtColor.emeraldDark),
                (0.5, 0.405, ArtColor.ruby, ArtColor.rubyDark),
                (0.6, 0.405, ArtColor.emerald, ArtColor.emeraldDark)
            ]
            for gem in tipGems {
                context.fill(a.circle(gem.x, gem.y, radius: 0.03), with: .color(gem.dark))
                context.fill(a.circle(gem.x, gem.y, radius: 0.02), with: .color(gem.light))
            }

            context.fill(a.sparkle(0.77, 0.12, radius: 0.06), with: .color(.white.opacity(0.95)))
            context.fill(a.sparkle(0.24, 0.3, radius: 0.04), with: .color(.white.opacity(0.8)))
        }
    }
}

#Preview {
    CrownPedestalArt()
        .frame(width: 180, height: 180)
        .padding()
        .background(VaultPalette.caveShadow)
}
