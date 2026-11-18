//
//  PedestalArt.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

/// The stone base under every item. Drawn in a wide frame, roughly 5:2.
struct PedestalArt: View {
    enum Look {
        case empty
        case occupied
        case rubble
    }

    let look: Look

    var body: some View {
        Canvas { context, size in
            let a = ArtSpace(size: size)
            switch look {
            case .rubble: drawRubble(context, a)
            case .empty, .occupied: drawPedestal(context, a)
            }
        }
    }

    private func drawPedestal(_ context: GraphicsContext, _ a: ArtSpace) {
        context.fill(a.ellipse(0, 0.5, 1, 0.5), with: .color(.black.opacity(0.35)))
        context.fill(a.ellipse(0.04, 0.38, 0.92, 0.56), with: .color(VaultPalette.stoneDark))
        context.fill(
            a.box(0.04, 0.3, 0.92, 0.36),
            with: a.horizontal([VaultPalette.stoneDark, VaultPalette.stone, VaultPalette.stoneDark])
        )

        let top = a.ellipse(0.04, 0.02, 0.92, 0.56)
        context.fill(top, with: a.vertical([VaultPalette.stoneLight, VaultPalette.stone], from: 0.02, to: 0.58))
        context.stroke(
            a.ellipse(0.16, 0.1, 0.68, 0.4),
            with: .color(VaultPalette.stoneDark.opacity(0.45)),
            lineWidth: a.u(0.03)
        )
        context.stroke(
            top,
            with: .color(look == .occupied ? VaultPalette.gold : VaultPalette.stoneLight.opacity(0.7)),
            lineWidth: a.u(look == .occupied ? 0.05 : 0.035)
        )
    }

    private func drawRubble(_ context: GraphicsContext, _ a: ArtSpace) {
        context.fill(a.ellipse(0.02, 0.55, 0.96, 0.45), with: .color(.black.opacity(0.3)))

        var mound = Path()
        mound.move(to: a.p(0.06, 0.9))
        mound.addCurve(to: a.p(0.94, 0.9), control1: a.p(0.2, 0.05), control2: a.p(0.8, 0.05))
        mound.closeSubpath()
        context.fill(mound, with: a.vertical([VaultPalette.caveRockLight, VaultPalette.caveRock], from: 0.2, to: 0.9))

        let stones: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (0.14, 0.62, 0.22, 0.26), (0.62, 0.58, 0.26, 0.3), (0.4, 0.7, 0.2, 0.22)
        ]
        for stone in stones {
            context.fill(
                a.ellipse(stone.0, stone.1, stone.2, stone.3),
                with: .color(VaultPalette.stoneDark.opacity(0.8))
            )
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        PedestalArt(look: .empty).frame(width: 140, height: 56)
        PedestalArt(look: .occupied).frame(width: 140, height: 56)
        PedestalArt(look: .rubble).frame(width: 140, height: 56)
    }
    .padding()
    .background(VaultPalette.caveShadow)
}
