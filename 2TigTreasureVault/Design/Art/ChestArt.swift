//
//  ChestArt.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

struct ChestArt: View {
    enum Style {
        case oak
        case gilded
    }

    let style: Style

    var body: some View {
        Canvas { context, size in
            let art = ArtSpace(size: size)
            switch style {
            case .oak: drawOak(context, art)
            case .gilded: drawGilded(context, art)
            }
        }
    }

    // MARK: Oak, closed

    private func drawOak(_ context: GraphicsContext, _ a: ArtSpace) {
        context.fill(a.ellipse(0.1, 0.83, 0.8, 0.12), with: .color(.black.opacity(0.35)))

        let body = a.rounded(0.14, 0.5, 0.72, 0.38, radius: 0.04)
        context.fill(body, with: a.vertical([ArtColor.wood, ArtColor.woodDark], from: 0.5, to: 0.88))

        let plankLines: [CGFloat] = [0.63, 0.76]
        for y in plankLines {
            context.stroke(
                a.line([(0.15, y), (0.85, y)]),
                with: .color(ArtColor.woodDark.opacity(0.8)),
                lineWidth: a.u(0.012)
            )
        }

        var lid = Path()
        lid.move(to: a.p(0.14, 0.52))
        lid.addLine(to: a.p(0.14, 0.42))
        lid.addCurve(to: a.p(0.86, 0.42), control1: a.p(0.14, 0.2), control2: a.p(0.86, 0.2))
        lid.addLine(to: a.p(0.86, 0.52))
        lid.closeSubpath()
        context.fill(lid, with: a.vertical([ArtColor.woodLight, ArtColor.wood], from: 0.24, to: 0.52))

        // Metal bands follow the silhouette.
        var silhouette = body
        silhouette.addPath(lid)
        var banded = context
        banded.clip(to: silhouette)
        let bandColumns: [CGFloat] = [0.25, 0.68]
        for x in bandColumns {
            banded.fill(
                a.box(x, 0.15, 0.07, 0.8),
                with: a.vertical([VaultPalette.goldLight, VaultPalette.gold, VaultPalette.goldDeep], from: 0.25, to: 0.9)
            )
        }

        context.fill(a.box(0.14, 0.5, 0.72, 0.03), with: .color(ArtColor.woodDark))
        context.fill(a.rounded(0.44, 0.45, 0.12, 0.15, radius: 0.025), with: .color(VaultPalette.gold))
        context.fill(a.circle(0.5, 0.515, radius: 0.022), with: .color(ArtColor.woodDark))
    }

    // MARK: Gilded, open and overflowing

    private func drawGilded(_ context: GraphicsContext, _ a: ArtSpace) {
        context.fill(
            a.circle(0.5, 0.45, radius: 0.5),
            with: a.radial([VaultPalette.gold.opacity(0.3), .clear], cx: 0.5, cy: 0.45, radius: 0.5)
        )
        context.fill(a.ellipse(0.1, 0.83, 0.8, 0.12), with: .color(.black.opacity(0.35)))

        // Open lid behind the hoard.
        context.fill(
            a.polygon([(0.17, 0.5), (0.2, 0.2), (0.8, 0.2), (0.83, 0.5)]),
            with: a.vertical([VaultPalette.goldDeep, ArtColor.woodDark], from: 0.2, to: 0.5)
        )
        context.fill(
            a.polygon([(0.22, 0.49), (0.245, 0.26), (0.755, 0.26), (0.78, 0.49)]),
            with: .color(ArtColor.crimsonDark)
        )
        context.fill(a.rounded(0.18, 0.17, 0.64, 0.05, radius: 0.02), with: .color(VaultPalette.goldLight))

        let coins: [(CGFloat, CGFloat)] = [
            (0.3, 0.4), (0.5, 0.36), (0.68, 0.41), (0.4, 0.43), (0.58, 0.45), (0.28, 0.47), (0.72, 0.48), (0.48, 0.48)
        ]
        for coin in coins {
            CoinPileArt.drawCoin(context, a, cx: coin.0, cy: coin.1, width: 0.2)
        }

        let body = a.rounded(0.14, 0.5, 0.72, 0.38, radius: 0.04)
        context.fill(body, with: a.vertical([VaultPalette.gold, VaultPalette.goldDeep], from: 0.5, to: 0.88))

        var banded = context
        banded.clip(to: body)
        let bandColumns: [CGFloat] = [0.25, 0.68]
        for x in bandColumns {
            banded.fill(a.box(x, 0.5, 0.07, 0.4), with: .color(VaultPalette.goldLight.opacity(0.85)))
        }
        context.fill(a.box(0.14, 0.5, 0.72, 0.045), with: .color(VaultPalette.goldLight))

        drawGem(context, a, cx: 0.5, cy: 0.71, radius: 0.055, light: ArtColor.ruby, dark: ArtColor.rubyDark)
        drawGem(context, a, cx: 0.285, cy: 0.71, radius: 0.028, light: ArtColor.sapphire, dark: ArtColor.sapphireDark)
        drawGem(context, a, cx: 0.715, cy: 0.71, radius: 0.028, light: ArtColor.emerald, dark: ArtColor.emeraldDark)

        context.fill(a.sparkle(0.76, 0.3, radius: 0.06), with: .color(.white.opacity(0.9)))
        context.fill(a.sparkle(0.3, 0.33, radius: 0.04), with: .color(.white.opacity(0.8)))
    }

    private func drawGem(
        _ context: GraphicsContext,
        _ a: ArtSpace,
        cx: CGFloat,
        cy: CGFloat,
        radius: CGFloat,
        light: Color,
        dark: Color
    ) {
        context.fill(a.circle(cx, cy, radius: radius), with: .color(dark))
        context.fill(a.circle(cx, cy, radius: radius * 0.72), with: .color(light))
        context.fill(
            a.circle(cx - radius * 0.25, cy - radius * 0.3, radius: radius * 0.22),
            with: .color(.white.opacity(0.85))
        )
    }
}

#Preview {
    HStack {
        ChestArt(style: .oak).frame(width: 140, height: 140)
        ChestArt(style: .gilded).frame(width: 140, height: 140)
    }
    .padding()
    .background(VaultPalette.caveShadow)
}
