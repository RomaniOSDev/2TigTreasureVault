//
//  CoinPileArt.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

struct CoinPileArt: View {
    var body: some View {
        Canvas { context, size in
            let a = ArtSpace(size: size)

            context.fill(
                a.circle(0.5, 0.6, radius: 0.5),
                with: a.radial([VaultPalette.gold.opacity(0.25), .clear], cx: 0.5, cy: 0.6, radius: 0.5)
            )
            context.fill(a.ellipse(0.06, 0.8, 0.88, 0.14), with: .color(.black.opacity(0.35)))

            // Bottom row first, so upper coins overlap the ones below.
            let rows: [(y: CGFloat, xs: [CGFloat])] = [
                (0.82, [0.2, 0.4, 0.6, 0.8]),
                (0.72, [0.3, 0.5, 0.7]),
                (0.62, [0.4, 0.6]),
                (0.52, [0.5])
            ]
            for row in rows {
                for x in row.xs {
                    Self.drawCoin(context, a, cx: x, cy: row.y, width: 0.27)
                }
            }

            context.fill(a.sparkle(0.64, 0.4, radius: 0.07), with: .color(.white.opacity(0.9)))
            context.fill(a.sparkle(0.24, 0.62, radius: 0.045), with: .color(.white.opacity(0.75)))
        }
    }

    /// One coin seen at an angle: a dark edge with a bright face on top.
    static func drawCoin(_ context: GraphicsContext, _ a: ArtSpace, cx: CGFloat, cy: CGFloat, width: CGFloat) {
        let height = width * 0.42
        let edge = width * 0.13
        let left = cx - width / 2
        let top = cy - height / 2

        context.fill(a.ellipse(left, top + edge, width, height), with: .color(VaultPalette.goldDeep))
        context.fill(a.box(left, cy, width, edge), with: .color(VaultPalette.goldDeep))
        context.fill(
            a.ellipse(left, top, width, height),
            with: .linearGradient(
                Gradient(colors: [VaultPalette.goldLight, VaultPalette.gold]),
                startPoint: a.p(cx, top),
                endPoint: a.p(cx, top + height)
            )
        )
        context.stroke(
            a.ellipse(left + width * 0.16, top + height * 0.2, width * 0.68, height * 0.6),
            with: .color(VaultPalette.goldDeep.opacity(0.55)),
            lineWidth: a.u(0.008)
        )
    }
}

#Preview {
    CoinPileArt()
        .frame(width: 160, height: 160)
        .padding()
        .background(VaultPalette.caveShadow)
}
