//
//  TigerStatueArt.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

/// The magic golden tiger: seated, facing the keeper, eyes alight.
struct TigerStatueArt: View {
    var body: some View {
        Canvas { context, size in
            let a = ArtSpace(size: size)
            let goldFill = a.vertical([VaultPalette.goldLight, VaultPalette.gold, VaultPalette.goldDeep], from: 0.12, to: 0.9)
            let stripe = VaultPalette.goldDeep
            let outline = Color(hex: 0x6B3F0A)
            let stripeStyle = StrokeStyle(lineWidth: a.u(0.022), lineCap: .round)

            context.fill(
                a.circle(0.5, 0.5, radius: 0.5),
                with: a.radial([VaultPalette.gold.opacity(0.4), .clear], cx: 0.5, cy: 0.5, radius: 0.5)
            )
            context.fill(a.ellipse(0.1, 0.86, 0.8, 0.1), with: .color(.black.opacity(0.35)))
            context.fill(
                a.rounded(0.18, 0.86, 0.64, 0.09, radius: 0.02),
                with: a.vertical([VaultPalette.goldDeep, outline], from: 0.86, to: 0.95)
            )

            // Tail curling up on the right.
            var tail = Path()
            tail.move(to: a.p(0.67, 0.83))
            tail.addCurve(to: a.p(0.86, 0.58), control1: a.p(0.86, 0.86), control2: a.p(0.92, 0.7))
            tail.addCurve(to: a.p(0.79, 0.5), control1: a.p(0.85, 0.52), control2: a.p(0.82, 0.49))
            context.stroke(tail, with: .color(outline), style: StrokeStyle(lineWidth: a.u(0.075), lineCap: .round))
            context.stroke(tail, with: .color(VaultPalette.gold), style: StrokeStyle(lineWidth: a.u(0.05), lineCap: .round))

            // Seated body.
            var body = Path()
            body.move(to: a.p(0.29, 0.88))
            body.addCurve(to: a.p(0.36, 0.5), control1: a.p(0.23, 0.75), control2: a.p(0.26, 0.58))
            body.addCurve(to: a.p(0.64, 0.5), control1: a.p(0.45, 0.44), control2: a.p(0.55, 0.44))
            body.addCurve(to: a.p(0.71, 0.88), control1: a.p(0.74, 0.58), control2: a.p(0.77, 0.75))
            body.closeSubpath()
            context.fill(body, with: goldFill)
            context.stroke(body, with: .color(outline), lineWidth: a.u(0.012))

            let bodyStripes: [[(CGFloat, CGFloat)]] = [
                [(0.285, 0.64), (0.345, 0.66)], [(0.27, 0.72), (0.335, 0.74)], [(0.275, 0.8), (0.335, 0.81)],
                [(0.715, 0.64), (0.655, 0.66)], [(0.73, 0.72), (0.665, 0.74)], [(0.725, 0.8), (0.665, 0.81)]
            ]
            for points in bodyStripes {
                context.stroke(a.line(points), with: .color(stripe), style: stripeStyle)
            }

            context.fill(a.ellipse(0.41, 0.55, 0.18, 0.26), with: .color(VaultPalette.goldLight.opacity(0.75)))

            // Front legs and paws.
            let legColumns: [CGFloat] = [0.365, 0.525]
            for x in legColumns {
                let leg = a.rounded(x, 0.64, 0.11, 0.25, radius: 0.045)
                context.fill(leg, with: goldFill)
                context.stroke(leg, with: .color(outline), lineWidth: a.u(0.01))
                context.fill(a.ellipse(x - 0.015, 0.84, 0.14, 0.06), with: .color(VaultPalette.goldLight))
            }

            // Ears.
            let ears: [[(CGFloat, CGFloat)]] = [
                [(0.29, 0.3), (0.31, 0.11), (0.46, 0.19)],
                [(0.71, 0.3), (0.69, 0.11), (0.54, 0.19)]
            ]
            for ear in ears {
                context.fill(a.polygon(ear), with: goldFill)
                context.stroke(a.polygon(ear), with: .color(outline), lineWidth: a.u(0.012))
            }
            context.fill(a.polygon([(0.325, 0.25), (0.335, 0.16), (0.4, 0.2)]), with: .color(stripe))
            context.fill(a.polygon([(0.675, 0.25), (0.665, 0.16), (0.6, 0.2)]), with: .color(stripe))

            // Head.
            let head = a.ellipse(0.27, 0.15, 0.46, 0.38)
            context.fill(head, with: goldFill)
            context.stroke(head, with: .color(outline), lineWidth: a.u(0.012))

            let faceStripes: [[(CGFloat, CGFloat)]] = [
                [(0.5, 0.17), (0.5, 0.25)], [(0.44, 0.18), (0.455, 0.25)], [(0.56, 0.18), (0.545, 0.25)],
                [(0.285, 0.34), (0.35, 0.36)], [(0.295, 0.41), (0.355, 0.415)],
                [(0.715, 0.34), (0.65, 0.36)], [(0.705, 0.41), (0.645, 0.415)]
            ]
            for points in faceStripes {
                context.stroke(a.line(points), with: .color(stripe), style: stripeStyle)
            }

            // Muzzle, nose and mouth.
            context.fill(a.ellipse(0.395, 0.36, 0.21, 0.145), with: .color(VaultPalette.goldLight))
            context.fill(a.polygon([(0.465, 0.385), (0.535, 0.385), (0.5, 0.425)]), with: .color(outline))
            var mouth = Path()
            mouth.move(to: a.p(0.5, 0.425))
            mouth.addLine(to: a.p(0.5, 0.45))
            mouth.addQuadCurve(to: a.p(0.44, 0.455), control: a.p(0.47, 0.485))
            mouth.move(to: a.p(0.5, 0.45))
            mouth.addQuadCurve(to: a.p(0.56, 0.455), control: a.p(0.53, 0.485))
            context.stroke(mouth, with: .color(outline), style: StrokeStyle(lineWidth: a.u(0.012), lineCap: .round))

            // Glowing eyes.
            let eyeColumns: [CGFloat] = [0.4, 0.6]
            for x in eyeColumns {
                context.fill(
                    a.circle(x, 0.315, radius: 0.07),
                    with: a.radial([VaultPalette.safety.opacity(0.7), .clear], cx: x, cy: 0.315, radius: 0.07)
                )
                context.fill(a.ellipse(x - 0.042, 0.288, 0.084, 0.056), with: .color(VaultPalette.safety))
                context.fill(a.ellipse(x - 0.012, 0.29, 0.024, 0.052), with: .color(outline))
            }

            context.fill(a.sparkle(0.78, 0.2, radius: 0.055), with: .color(.white.opacity(0.9)))
        }
    }
}

#Preview {
    TigerStatueArt()
        .frame(width: 220, height: 220)
        .padding()
        .background(VaultPalette.caveShadow)
}
