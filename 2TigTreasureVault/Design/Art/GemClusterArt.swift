//
//  GemClusterArt.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

struct GemClusterArt: View {
    var body: some View {
        Canvas { context, size in
            let a = ArtSpace(size: size)

            context.fill(
                a.circle(0.5, 0.5, radius: 0.5),
                with: a.radial([ArtColor.ruby.opacity(0.28), .clear], cx: 0.5, cy: 0.5, radius: 0.5)
            )
            context.fill(a.ellipse(0.1, 0.8, 0.8, 0.14), with: .color(.black.opacity(0.35)))

            // Side crystals sit behind the tall one.
            drawCrystal(
                context, a,
                left: [(0.26, 0.86), (0.13, 0.52), (0.2, 0.37), (0.3, 0.86)],
                right: [(0.3, 0.86), (0.2, 0.37), (0.33, 0.5), (0.42, 0.86)],
                light: ArtColor.sapphire, dark: ArtColor.sapphireDark
            )
            drawCrystal(
                context, a,
                left: [(0.58, 0.86), (0.69, 0.48), (0.81, 0.34), (0.72, 0.86)],
                right: [(0.72, 0.86), (0.81, 0.34), (0.89, 0.52), (0.78, 0.86)],
                light: ArtColor.emerald, dark: ArtColor.emeraldDark
            )
            drawCrystal(
                context, a,
                left: [(0.41, 0.88), (0.37, 0.38), (0.5, 0.13), (0.5, 0.88)],
                right: [(0.5, 0.88), (0.5, 0.13), (0.63, 0.38), (0.59, 0.88)],
                light: ArtColor.ruby, dark: ArtColor.rubyDark
            )

            // Rock the crystals grow from.
            var rock = Path()
            rock.move(to: a.p(0.14, 0.92))
            rock.addCurve(to: a.p(0.86, 0.92), control1: a.p(0.24, 0.76), control2: a.p(0.76, 0.76))
            rock.closeSubpath()
            context.fill(rock, with: a.vertical([VaultPalette.stone, VaultPalette.stoneDark], from: 0.78, to: 0.92))

            context.fill(a.sparkle(0.5, 0.15, radius: 0.07), with: .color(.white.opacity(0.95)))
            context.fill(a.sparkle(0.82, 0.36, radius: 0.045), with: .color(.white.opacity(0.85)))
            context.fill(a.sparkle(0.19, 0.4, radius: 0.04), with: .color(.white.opacity(0.8)))
        }
    }

    private func drawCrystal(
        _ context: GraphicsContext,
        _ a: ArtSpace,
        left: [(CGFloat, CGFloat)],
        right: [(CGFloat, CGFloat)],
        light: Color,
        dark: Color
    ) {
        context.fill(a.polygon(left), with: .color(light))
        context.fill(a.polygon(right), with: .color(dark))
        context.stroke(a.polygon(left), with: .color(.white.opacity(0.35)), lineWidth: a.u(0.008))
    }
}

#Preview {
    GemClusterArt()
        .frame(width: 160, height: 160)
        .padding()
        .background(VaultPalette.caveShadow)
}
