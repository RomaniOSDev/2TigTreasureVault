//
//  FireArt.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

/// Standing torch: a pole, an iron cup and a live flame.
struct TorchArt: View {
    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [VaultPalette.ember.opacity(0.45), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: side * 0.42
                        )
                    )
                    .frame(width: side * 0.84, height: side * 0.84)
                    .position(x: geo.size.width / 2, y: side * 0.24)

                Canvas { context, size in
                    let a = ArtSpace(size: size)
                    context.fill(a.ellipse(0.28, 0.87, 0.44, 0.09), with: .color(.black.opacity(0.35)))
                    context.fill(a.rounded(0.36, 0.87, 0.28, 0.07, radius: 0.02), with: .color(VaultPalette.stoneDark))
                    context.fill(
                        a.box(0.46, 0.42, 0.08, 0.47),
                        with: a.horizontal([ArtColor.woodLight, ArtColor.woodDark], from: 0.46, to: 0.54)
                    )
                    context.fill(a.box(0.445, 0.6, 0.11, 0.04), with: .color(VaultPalette.goldDeep))
                    context.fill(
                        a.polygon([(0.36, 0.36), (0.64, 0.36), (0.58, 0.47), (0.42, 0.47)]),
                        with: a.vertical([ArtColor.iron, ArtColor.ironDark], from: 0.36, to: 0.47)
                    )
                    context.fill(a.rounded(0.34, 0.335, 0.32, 0.045, radius: 0.015), with: .color(VaultPalette.goldDeep))
                }

                FlameView()
                    .frame(width: side * 0.28, height: side * 0.34)
                    .position(x: geo.size.width / 2, y: side * 0.185)
            }
        }
    }
}

/// Iron bowl on three legs with a larger fire.
struct BrazierArt: View {
    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [VaultPalette.ember.opacity(0.5), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: side * 0.5
                        )
                    )
                    .frame(width: side, height: side)
                    .position(x: geo.size.width / 2, y: side * 0.34)

                Canvas { context, size in
                    let a = ArtSpace(size: size)
                    context.fill(a.ellipse(0.16, 0.86, 0.68, 0.1), with: .color(.black.opacity(0.35)))

                    let legs: [[(CGFloat, CGFloat)]] = [
                        [(0.36, 0.6), (0.25, 0.92)],
                        [(0.64, 0.6), (0.75, 0.92)],
                        [(0.5, 0.64), (0.5, 0.93)]
                    ]
                    for leg in legs {
                        context.stroke(
                            a.line(leg),
                            with: .color(ArtColor.ironDark),
                            style: StrokeStyle(lineWidth: a.u(0.05), lineCap: .round)
                        )
                    }

                    var bowl = Path()
                    bowl.move(to: a.p(0.19, 0.5))
                    bowl.addCurve(to: a.p(0.81, 0.5), control1: a.p(0.25, 0.74), control2: a.p(0.75, 0.74))
                    bowl.closeSubpath()
                    context.fill(bowl, with: a.vertical([ArtColor.iron, ArtColor.ironDark], from: 0.5, to: 0.7))

                    context.fill(a.ellipse(0.24, 0.45, 0.52, 0.08), with: .color(VaultPalette.ember))
                    context.fill(
                        a.rounded(0.17, 0.47, 0.66, 0.05, radius: 0.02),
                        with: a.vertical([VaultPalette.gold, VaultPalette.goldDeep], from: 0.47, to: 0.52)
                    )
                }

                FlameView()
                    .frame(width: side * 0.4, height: side * 0.42)
                    .position(x: geo.size.width / 2, y: side * 0.27)
            }
        }
    }
}

#Preview {
    HStack {
        TorchArt().frame(width: 140, height: 140)
        BrazierArt().frame(width: 140, height: 140)
    }
    .padding()
    .background(VaultPalette.caveShadow)
}
