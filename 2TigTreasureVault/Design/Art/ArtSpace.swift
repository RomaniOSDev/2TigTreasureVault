//
//  ArtSpace.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

/// Maps 0...1 art coordinates onto a canvas, so every drawing scales with its frame.
struct ArtSpace {
    let size: CGSize

    var w: CGFloat { size.width }
    var h: CGFloat { size.height }

    func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(x: x * w, y: y * h)
    }

    /// A length relative to the shorter side. Use for line widths and corner radii.
    func u(_ value: CGFloat) -> CGFloat {
        value * min(w, h)
    }

    func rect(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        CGRect(x: x * w, y: y * h, width: width * w, height: height * h)
    }

    func box(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> Path {
        Path(rect(x, y, width, height))
    }

    func rounded(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat, radius: CGFloat) -> Path {
        Path(roundedRect: rect(x, y, width, height), cornerRadius: u(radius), style: .continuous)
    }

    func ellipse(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> Path {
        Path(ellipseIn: rect(x, y, width, height))
    }

    /// Circle given by its center and a radius relative to the shorter side.
    func circle(_ cx: CGFloat, _ cy: CGFloat, radius: CGFloat) -> Path {
        let r = u(radius)
        let center = p(cx, cy)
        return Path(ellipseIn: CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2))
    }

    func polygon(_ points: [(CGFloat, CGFloat)]) -> Path {
        var path = line(points)
        path.closeSubpath()
        return path
    }

    func line(_ points: [(CGFloat, CGFloat)]) -> Path {
        var path = Path()
        for (index, point) in points.enumerated() {
            if index == 0 {
                path.move(to: p(point.0, point.1))
            } else {
                path.addLine(to: p(point.0, point.1))
            }
        }
        return path
    }

    /// Four-pointed glint.
    func sparkle(_ cx: CGFloat, _ cy: CGFloat, radius: CGFloat) -> Path {
        let r = radius
        let inner = radius * 0.22
        return polygon([
            (cx, cy - r), (cx + inner, cy - inner),
            (cx + r, cy), (cx + inner, cy + inner),
            (cx, cy + r), (cx - inner, cy + inner),
            (cx - r, cy), (cx - inner, cy - inner)
        ])
    }

    func vertical(_ colors: [Color], from: CGFloat = 0, to: CGFloat = 1) -> GraphicsContext.Shading {
        .linearGradient(Gradient(colors: colors), startPoint: p(0.5, from), endPoint: p(0.5, to))
    }

    func horizontal(_ colors: [Color], from: CGFloat = 0, to: CGFloat = 1) -> GraphicsContext.Shading {
        .linearGradient(Gradient(colors: colors), startPoint: p(from, 0.5), endPoint: p(to, 0.5))
    }

    func radial(_ colors: [Color], cx: CGFloat, cy: CGFloat, radius: CGFloat) -> GraphicsContext.Shading {
        .radialGradient(Gradient(colors: colors), center: p(cx, cy), startRadius: 0, endRadius: u(radius))
    }
}

/// Material colors that only drawings use.
enum ArtColor {
    static let woodLight = Color(hex: 0xA86C36)
    static let wood = Color(hex: 0x7E4E25)
    static let woodDark = Color(hex: 0x4A2B13)
    static let iron = Color(hex: 0x4A3F48)
    static let ironDark = Color(hex: 0x2A2229)
    static let crimson = Color(hex: 0xA3233B)
    static let crimsonDark = Color(hex: 0x6A1526)
    static let ruby = Color(hex: 0xFF5C7A)
    static let rubyDark = Color(hex: 0xB32348)
    static let emerald = Color(hex: 0x58E0A4)
    static let emeraldDark = Color(hex: 0x1F8E63)
    static let sapphire = Color(hex: 0x6CC4FF)
    static let sapphireDark = Color(hex: 0x2670B8)
    static let sack = Color(hex: 0x8A6238)
    static let sackDark = Color(hex: 0x5A3D20)
    static let socket = Color(hex: 0x081A2E)
}
