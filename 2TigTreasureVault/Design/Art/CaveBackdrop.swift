//
//  CaveBackdrop.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

/// The cave itself: vaulted ceiling, stalactites, a lit floor and a far-off glimmer of gold.
/// Drawn once and never animated, so it is cheap to keep on screen.
struct CaveBackdrop: View {
    enum Mood {
        /// Warm firelight for the vault.
        case calm
        /// Cold light spilling in while thieves are at the gate.
        case raid
    }

    var mood: Mood = .calm

    var body: some View {
        Canvas { context, size in
            let a = ArtSpace(size: size)
            let glow = mood == .calm ? VaultPalette.ember : VaultPalette.spectral
            let accent = mood == .calm ? VaultPalette.gold : VaultPalette.spectral

            context.fill(
                a.box(0, 0, 1, 1),
                with: a.vertical([VaultPalette.caveDeep, VaultPalette.caveShadow, VaultPalette.caveRock, VaultPalette.caveDeep])
            )

            // Light at the back of the cave.
            context.fill(
                a.box(0, 0, 1, 1),
                with: .radialGradient(
                    Gradient(colors: [glow.opacity(0.42), accent.opacity(0.12), .clear]),
                    center: a.p(0.5, 0.3),
                    startRadius: 0,
                    endRadius: a.h * 0.42
                )
            )

            if mood == .calm {
                drawFarHoard(context, a)
            } else {
                drawGate(context, a)
            }
            drawFloor(context, a, accent: accent)
            drawCeiling(context, a)

            // Darken the edges so the middle reads as lit.
            context.fill(
                a.box(0, 0, 1, 1),
                with: .radialGradient(
                    Gradient(colors: [.clear, .black.opacity(0.55)]),
                    center: a.p(0.5, 0.55),
                    startRadius: a.h * 0.3,
                    endRadius: a.h * 0.72
                )
            )
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func drawFarHoard(_ context: GraphicsContext, _ a: ArtSpace) {
        var mound = Path()
        mound.move(to: a.p(0.12, 0.33))
        mound.addCurve(to: a.p(0.88, 0.33), control1: a.p(0.3, 0.2), control2: a.p(0.7, 0.2))
        mound.closeSubpath()
        context.fill(
            mound,
            with: a.vertical([VaultPalette.gold.opacity(0.45), VaultPalette.goldDeep.opacity(0.25)], from: 0.22, to: 0.33)
        )

        let glints: [(CGFloat, CGFloat, CGFloat)] = [
            (0.3, 0.29, 0.012), (0.42, 0.255, 0.016), (0.5, 0.27, 0.01),
            (0.58, 0.25, 0.014), (0.68, 0.285, 0.011), (0.36, 0.31, 0.009), (0.62, 0.305, 0.009)
        ]
        for glint in glints {
            context.fill(
                a.circle(glint.0, glint.1, radius: glint.2),
                with: .color(VaultPalette.goldLight.opacity(0.85))
            )
        }
    }

    /// Dark tunnel mouth the thieves pour out of.
    private func drawGate(_ context: GraphicsContext, _ a: ArtSpace) {
        var gate = Path()
        gate.move(to: a.p(0.27, 0.36))
        gate.addLine(to: a.p(0.27, 0.27))
        gate.addCurve(to: a.p(0.73, 0.27), control1: a.p(0.27, 0.17), control2: a.p(0.73, 0.17))
        gate.addLine(to: a.p(0.73, 0.36))
        gate.closeSubpath()

        context.fill(gate, with: a.vertical([.black, VaultPalette.spectralDeep.opacity(0.9)], from: 0.19, to: 0.36))
        context.stroke(gate, with: .color(VaultPalette.spectral.opacity(0.55)), lineWidth: a.u(0.012))
    }

    private func drawFloor(_ context: GraphicsContext, _ a: ArtSpace, accent: Color) {
        var floor = Path()
        floor.move(to: a.p(0, 0.345))
        floor.addQuadCurve(to: a.p(1, 0.345), control: a.p(0.5, 0.305))
        floor.addLine(to: a.p(1, 1))
        floor.addLine(to: a.p(0, 1))
        floor.closeSubpath()
        context.fill(
            floor,
            with: a.vertical([VaultPalette.caveFloor, VaultPalette.caveRock, VaultPalette.caveDeep], from: 0.32, to: 1)
        )

        // Pool of light where the treasures stand.
        context.fill(
            floor,
            with: .radialGradient(
                Gradient(colors: [accent.opacity(0.16), .clear]),
                center: a.p(0.5, 0.6),
                startRadius: 0,
                endRadius: a.w * 0.75
            )
        )

        // Worn flagstones: lines fanning out from the back, crossed by a few arcs.
        var seams = context
        seams.clip(to: floor)
        let fan: [CGFloat] = [-0.5, -0.05, 0.3, 0.7, 1.05, 1.5]
        for x in fan {
            seams.stroke(
                a.line([(0.5, 0.2), (x, 1)]),
                with: .color(.black.opacity(0.16)),
                lineWidth: a.u(0.004)
            )
        }
        let arcs: [CGFloat] = [0.42, 0.52, 0.66, 0.84]
        for y in arcs {
            var arc = Path()
            arc.move(to: a.p(0, y + 0.03))
            arc.addQuadCurve(to: a.p(1, y + 0.03), control: a.p(0.5, y - 0.03))
            seams.stroke(arc, with: .color(.black.opacity(0.16)), lineWidth: a.u(0.004))
        }
    }

    private func drawCeiling(_ context: GraphicsContext, _ a: ArtSpace) {
        var ceiling = Path()
        ceiling.move(to: a.p(0, 0))
        ceiling.addLine(to: a.p(1, 0))
        ceiling.addLine(to: a.p(1, 0.31))
        ceiling.addCurve(to: a.p(0.5, 0.15), control1: a.p(0.93, 0.2), control2: a.p(0.72, 0.15))
        ceiling.addCurve(to: a.p(0, 0.31), control1: a.p(0.28, 0.15), control2: a.p(0.07, 0.2))
        ceiling.closeSubpath()
        context.fill(
            ceiling,
            with: a.vertical([VaultPalette.caveDeep, VaultPalette.caveRock], from: 0, to: 0.3)
        )

        // Stalactites: (center x, base y, half width, length).
        let spikes: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (0.06, 0.25, 0.035, 0.07), (0.17, 0.2, 0.03, 0.05), (0.29, 0.165, 0.028, 0.045),
            (0.43, 0.15, 0.022, 0.03), (0.6, 0.15, 0.025, 0.038), (0.73, 0.168, 0.03, 0.05),
            (0.85, 0.205, 0.028, 0.045), (0.95, 0.255, 0.035, 0.065)
        ]
        for spike in spikes {
            context.fill(
                a.polygon([
                    (spike.0 - spike.2, spike.1 - 0.01),
                    (spike.0 + spike.2, spike.1 - 0.01),
                    (spike.0, spike.1 + spike.3)
                ]),
                with: .color(VaultPalette.caveRock)
            )
        }
    }
}

#Preview {
    CaveBackdrop()
        .ignoresSafeArea()
}
