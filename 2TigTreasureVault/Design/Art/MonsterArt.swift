//
//  MonsterArt.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

/// Cave bat clutching a small coin bag. Drawn without a ground shadow because it flies.
struct BatArt: View {
    private let fur = Color(hex: 0x6B3FA8)
    private let furDark = Color(hex: 0x2F1A57)
    private let membrane = Color(hex: 0x8D5BD6)
    private let membraneDark = Color(hex: 0x4B2A85)

    var body: some View {
        Canvas { context, size in
            let a = ArtSpace(size: size)

            context.fill(
                a.circle(0.5, 0.48, radius: 0.5),
                with: a.radial([membrane.opacity(0.32), .clear], cx: 0.5, cy: 0.48, radius: 0.5)
            )

            for mirrored in [false, true] {
                // The right wing is the left one flipped around the middle.
                func x(_ value: CGFloat) -> CGFloat { mirrored ? 1 - value : value }

                var wing = Path()
                wing.move(to: a.p(x(0.45), 0.4))
                wing.addLine(to: a.p(x(0.21), 0.19))
                wing.addLine(to: a.p(x(0.03), 0.3))
                wing.addQuadCurve(to: a.p(x(0.12), 0.53), control: a.p(x(0.1), 0.38))
                wing.addQuadCurve(to: a.p(x(0.24), 0.57), control: a.p(x(0.17), 0.46))
                wing.addQuadCurve(to: a.p(x(0.36), 0.61), control: a.p(x(0.29), 0.5))
                wing.addLine(to: a.p(x(0.45), 0.57))
                wing.closeSubpath()
                context.fill(wing, with: a.vertical([membrane, membraneDark], from: 0.19, to: 0.61))
                context.stroke(wing, with: .color(furDark), lineWidth: a.u(0.012))

                for tip in [(0.12, 0.53), (0.24, 0.57), (0.36, 0.61)] as [(CGFloat, CGFloat)] {
                    context.stroke(
                        a.line([(x(0.21), 0.19), (x(tip.0), tip.1)]),
                        with: .color(furDark.opacity(0.7)),
                        style: StrokeStyle(lineWidth: a.u(0.012), lineCap: .round)
                    )
                }

                context.fill(
                    a.polygon([(x(0.39), 0.38), (x(0.38), 0.2), (x(0.48), 0.33)]),
                    with: .color(fur)
                )
                context.fill(
                    a.polygon([(x(0.405), 0.35), (x(0.4), 0.26), (x(0.45), 0.33)]),
                    with: .color(Color(hex: 0xE59AC0))
                )
            }

            // Coin bag hanging from its feet.
            context.stroke(
                a.line([(0.47, 0.68), (0.5, 0.76), (0.53, 0.68)]),
                with: .color(furDark),
                style: StrokeStyle(lineWidth: a.u(0.016), lineCap: .round, lineJoin: .round)
            )
            context.fill(
                a.ellipse(0.41, 0.74, 0.18, 0.17),
                with: a.vertical([ArtColor.sack, ArtColor.sackDark], from: 0.74, to: 0.91)
            )
            context.stroke(
                a.line([(0.45, 0.77), (0.55, 0.77)]),
                with: .color(VaultPalette.gold),
                style: StrokeStyle(lineWidth: a.u(0.018), lineCap: .round)
            )

            let body = a.ellipse(0.35, 0.31, 0.3, 0.39)
            context.fill(body, with: a.vertical([fur, furDark], from: 0.31, to: 0.7))
            context.stroke(body, with: .color(furDark), lineWidth: a.u(0.012))

            for cx in [0.44, 0.56] as [CGFloat] {
                context.fill(a.circle(cx, 0.45, radius: 0.042), with: .color(VaultPalette.goldLight))
                context.fill(a.circle(cx, 0.455, radius: 0.018), with: .color(furDark))
            }
            context.fill(a.polygon([(0.455, 0.55), (0.47, 0.61), (0.485, 0.55)]), with: .color(.white))
            context.fill(a.polygon([(0.515, 0.55), (0.53, 0.61), (0.545, 0.55)]), with: .color(.white))
        }
    }
}

/// Jelly that has swallowed a few coins. Slimelings reuse it at a smaller size.
struct SlimeArt: View {
    private let light = Color(hex: 0xD3FFA6)
    private let base = Color(hex: 0x74D84F)
    private let dark = Color(hex: 0x2C7A2B)

    var body: some View {
        Canvas { context, size in
            let a = ArtSpace(size: size)

            context.fill(
                a.circle(0.5, 0.6, radius: 0.5),
                with: a.radial([base.opacity(0.3), .clear], cx: 0.5, cy: 0.6, radius: 0.5)
            )
            context.fill(a.ellipse(0.17, 0.85, 0.66, 0.09), with: .color(.black.opacity(0.4)))

            var blob = Path()
            blob.move(to: a.p(0.14, 0.87))
            blob.addCurve(to: a.p(0.5, 0.3), control1: a.p(0.06, 0.6), control2: a.p(0.24, 0.3))
            blob.addCurve(to: a.p(0.86, 0.87), control1: a.p(0.76, 0.3), control2: a.p(0.94, 0.6))
            blob.addQuadCurve(to: a.p(0.14, 0.87), control: a.p(0.5, 0.95))
            blob.closeSubpath()

            context.fill(blob, with: a.vertical([light, base, dark], from: 0.3, to: 0.92))

            // Swallowed coins show through the jelly.
            for coin in [(0.3, 0.72), (0.47, 0.76), (0.6, 0.7)] as [(CGFloat, CGFloat)] {
                let shape = a.ellipse(coin.0, coin.1, 0.13, 0.07)
                context.fill(shape, with: .color(VaultPalette.gold.opacity(0.9)))
                context.stroke(shape, with: .color(VaultPalette.goldDeep), lineWidth: a.u(0.012))
            }
            context.fill(blob, with: .color(base.opacity(0.28)))
            context.stroke(blob, with: .color(dark), lineWidth: a.u(0.016))

            context.fill(a.ellipse(0.27, 0.42, 0.13, 0.08), with: .color(.white.opacity(0.55)))

            for cx in [0.4, 0.6] as [CGFloat] {
                context.fill(a.circle(cx, 0.56, radius: 0.06), with: .color(.white))
                context.fill(a.circle(cx + 0.01, 0.57, radius: 0.03), with: .color(Color(hex: 0x163A14)))
            }

            var mouth = Path()
            mouth.move(to: a.p(0.45, 0.65))
            mouth.addQuadCurve(to: a.p(0.55, 0.65), control: a.p(0.5, 0.7))
            context.stroke(
                mouth,
                with: .color(Color(hex: 0x163A14)),
                style: StrokeStyle(lineWidth: a.u(0.018), lineCap: .round)
            )
        }
    }
}

/// Pale spirit hugging a loot sack. Drawn without a ground shadow because it hovers.
struct GhostArt: View {
    private let light = Color(hex: 0xF4FBFF)
    private let base = Color(hex: 0xB4D6F2)
    private let edge = Color(hex: 0x6C98C4)

    var body: some View {
        Canvas { context, size in
            let a = ArtSpace(size: size)

            context.fill(
                a.circle(0.5, 0.5, radius: 0.5),
                with: a.radial([light.opacity(0.35), .clear], cx: 0.5, cy: 0.5, radius: 0.5)
            )

            var sheet = Path()
            sheet.move(to: a.p(0.24, 0.84))
            sheet.addLine(to: a.p(0.24, 0.42))
            sheet.addCurve(to: a.p(0.72, 0.42), control1: a.p(0.24, 0.06), control2: a.p(0.72, 0.06))
            sheet.addLine(to: a.p(0.72, 0.84))
            sheet.addQuadCurve(to: a.p(0.56, 0.84), control: a.p(0.64, 0.98))
            sheet.addQuadCurve(to: a.p(0.4, 0.84), control: a.p(0.48, 0.98))
            sheet.addQuadCurve(to: a.p(0.24, 0.84), control: a.p(0.32, 0.98))
            sheet.closeSubpath()

            context.fill(sheet, with: a.vertical([light, base], from: 0.1, to: 0.95))
            context.stroke(sheet, with: .color(edge), lineWidth: a.u(0.014))

            for cx in [0.35, 0.53] as [CGFloat] {
                context.fill(a.ellipse(cx, 0.3, 0.1, 0.14), with: .color(ArtColor.socket))
                context.fill(a.circle(cx + 0.05, 0.385, radius: 0.02), with: .color(VaultPalette.spectral))
            }
            context.fill(a.ellipse(0.44, 0.5, 0.09, 0.1), with: .color(ArtColor.socket))

            // Sack clutched at its side.
            context.fill(
                a.ellipse(0.6, 0.5, 0.28, 0.3),
                with: a.vertical([ArtColor.sack, ArtColor.sackDark], from: 0.5, to: 0.8)
            )
            context.fill(a.polygon([(0.68, 0.52), (0.73, 0.43), (0.8, 0.51)]), with: .color(ArtColor.sack))
            context.stroke(
                a.line([(0.69, 0.52), (0.79, 0.52)]),
                with: .color(VaultPalette.gold),
                style: StrokeStyle(lineWidth: a.u(0.02), lineCap: .round)
            )
            // Stubby arm over the sack.
            context.fill(a.ellipse(0.55, 0.58, 0.16, 0.08), with: .color(light))
            context.stroke(a.ellipse(0.55, 0.58, 0.16, 0.08), with: .color(edge), lineWidth: a.u(0.01))
        }
    }
}

#Preview {
    HStack {
        BatArt().frame(width: 110, height: 110)
        SlimeArt().frame(width: 110, height: 110)
        GhostArt().frame(width: 110, height: 110)
    }
    .padding()
    .background(VaultPalette.caveShadow)
}
