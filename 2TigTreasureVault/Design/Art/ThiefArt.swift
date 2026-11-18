//
//  ThiefArt.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

/// Portrait of anything that raids the vault. Skeletons are drawn here, other monsters in `MonsterArt`.
struct ThiefArt: View {
    let kind: ThiefKind

    var body: some View {
        switch kind {
        case .bat: BatArt()
        case .slime, .slimeling: SlimeArt()
        case .ghost: GhostArt()
        case .skeleton, .runner, .brute, .boneKing: SkeletonArt(kind: kind)
        }
    }
}

/// Spectral skeleton with a loot sack. Each kind gets its own tint and headgear.
private struct SkeletonArt: View {
    let kind: ThiefKind

    private struct Tones {
        let light: Color
        let base: Color
        let shade: Color
        let eye: Color
    }

    private var tones: Tones {
        switch kind {
        case .skeleton:
            Tones(light: Color(hex: 0xCDEBFF), base: VaultPalette.spectral, shade: VaultPalette.spectralDeep, eye: VaultPalette.goldLight)
        case .runner:
            Tones(light: Color(hex: 0xD6FFF9), base: Color(hex: 0x6FE3E0), shade: Color(hex: 0x1B7C86), eye: .white)
        case .brute:
            Tones(light: Color(hex: 0xDCD9FF), base: Color(hex: 0x8F8BFF), shade: Color(hex: 0x3A358F), eye: VaultPalette.danger)
        default:
            // The Bone King: old gilded bones and burning eyes.
            Tones(light: Color(hex: 0xFFF1C9), base: Color(hex: 0xE2B255), shade: Color(hex: 0x7A4E14), eye: VaultPalette.danger)
        }
    }

    var body: some View {
        Canvas { context, size in
            let a = ArtSpace(size: size)
            let t = tones
            let boneStroke = StrokeStyle(lineWidth: a.u(0.055), lineCap: .round, lineJoin: .round)

            context.fill(
                a.circle(0.5, 0.5, radius: 0.5),
                with: a.radial([t.base.opacity(0.35), .clear], cx: 0.5, cy: 0.5, radius: 0.5)
            )
            context.fill(a.ellipse(0.24, 0.9, 0.52, 0.07), with: .color(.black.opacity(0.4)))

            if kind == .boneKing {
                // A king carries no sack: a cape behind and a scepter in hand.
                context.fill(
                    a.polygon([(0.33, 0.48), (0.67, 0.48), (0.82, 0.9), (0.18, 0.9)]),
                    with: a.vertical([ArtColor.crimson, ArtColor.crimsonDark], from: 0.48, to: 0.9)
                )
                context.stroke(
                    a.line([(0.71, 0.5), (0.78, 0.16)]),
                    with: .color(VaultPalette.goldDeep),
                    style: StrokeStyle(lineWidth: a.u(0.03), lineCap: .round)
                )
                context.fill(a.circle(0.785, 0.14, radius: 0.05), with: .color(ArtColor.ruby))
                context.fill(a.circle(0.77, 0.125, radius: 0.016), with: .color(.white.opacity(0.8)))
            } else {
                // Loot sack over the shoulder.
                context.fill(
                    a.ellipse(0.56, 0.38, 0.33, 0.35),
                    with: a.vertical([ArtColor.sack, ArtColor.sackDark], from: 0.38, to: 0.73)
                )
                context.fill(a.polygon([(0.65, 0.4), (0.7, 0.3), (0.78, 0.39)]), with: .color(ArtColor.sack))
                context.stroke(
                    a.line([(0.66, 0.4), (0.77, 0.4)]),
                    with: .color(VaultPalette.gold),
                    style: StrokeStyle(lineWidth: a.u(0.02), lineCap: .round)
                )
            }

            // Legs and feet.
            context.stroke(a.line([(0.44, 0.74), (0.41, 0.92)]), with: .color(t.base), style: boneStroke)
            context.stroke(a.line([(0.56, 0.74), (0.59, 0.92)]), with: .color(t.base), style: boneStroke)
            context.fill(a.ellipse(0.33, 0.9, 0.13, 0.05), with: .color(t.light))
            context.fill(a.ellipse(0.54, 0.9, 0.13, 0.05), with: .color(t.light))

            // Arms.
            context.stroke(a.line([(0.37, 0.55), (0.25, 0.65), (0.31, 0.76)]), with: .color(t.base), style: boneStroke)
            context.stroke(a.line([(0.63, 0.55), (0.74, 0.48), (0.7, 0.41)]), with: .color(t.base), style: boneStroke)

            // Ribcage.
            context.fill(a.rounded(0.37, 0.5, 0.26, 0.27, radius: 0.07), with: .color(t.shade))
            let ribs: [CGFloat] = [0.57, 0.635, 0.7]
            for y in ribs {
                context.stroke(
                    a.line([(0.405, y), (0.595, y)]),
                    with: .color(t.light),
                    style: StrokeStyle(lineWidth: a.u(0.028), lineCap: .round)
                )
            }
            context.stroke(
                a.line([(0.5, 0.52), (0.5, 0.75)]),
                with: .color(t.base),
                style: StrokeStyle(lineWidth: a.u(0.03), lineCap: .round)
            )

            // Jaw sits under the skull.
            let jaw = a.rounded(0.38, 0.37, 0.24, 0.14, radius: 0.04)
            context.fill(jaw, with: .color(t.base))
            context.stroke(jaw, with: .color(t.shade), lineWidth: a.u(0.012))
            let teeth: [CGFloat] = [0.44, 0.5, 0.56]
            for x in teeth {
                context.stroke(a.line([(x, 0.43), (x, 0.5)]), with: .color(t.shade), lineWidth: a.u(0.014))
            }

            if kind == .brute {
                context.fill(a.polygon([(0.31, 0.2), (0.14, 0.03), (0.25, 0.27)]), with: .color(t.light))
                context.fill(a.polygon([(0.69, 0.2), (0.86, 0.03), (0.75, 0.27)]), with: .color(t.light))
            }

            let skull = a.ellipse(0.26, 0.08, 0.48, 0.38)
            context.fill(skull, with: a.vertical([t.light, t.base], from: 0.08, to: 0.46))
            context.stroke(skull, with: .color(t.shade), lineWidth: a.u(0.012))

            if kind == .runner {
                var banded = context
                banded.clip(to: skull)
                banded.fill(a.box(0.2, 0.15, 0.6, 0.06), with: .color(VaultPalette.ember))
                context.fill(a.polygon([(0.72, 0.17), (0.88, 0.12), (0.85, 0.23)]), with: .color(VaultPalette.ember))
            }

            if kind == .boneKing {
                context.fill(
                    a.polygon([
                        (0.31, 0.17), (0.29, 0.04), (0.4, 0.1), (0.5, 0.01),
                        (0.6, 0.1), (0.71, 0.04), (0.69, 0.17)
                    ]),
                    with: a.vertical([VaultPalette.goldLight, VaultPalette.gold, VaultPalette.goldDeep], from: 0.01, to: 0.17)
                )
                context.fill(a.circle(0.5, 0.115, radius: 0.026), with: .color(ArtColor.ruby))
            }

            let sockets: [CGFloat] = [0.335, 0.53]
            for x in sockets {
                context.fill(a.ellipse(x, 0.22, 0.135, 0.14), with: .color(ArtColor.socket))
                context.fill(a.circle(x + 0.068, 0.295, radius: 0.024), with: .color(t.eye))
            }
            context.fill(a.polygon([(0.5, 0.355), (0.475, 0.405), (0.525, 0.405)]), with: .color(ArtColor.socket))
        }
    }
}

#Preview {
    HStack {
        ForEach([ThiefKind.skeleton, .runner, .brute, .boneKing]) { kind in
            ThiefArt(kind: kind).frame(width: 90, height: 90)
        }
    }
    .padding()
    .background(VaultPalette.caveShadow)
}
