//
//  VaultTypography.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

/// Serif for headings (old ledgers), rounded for everything you read or count.
enum VaultFont {
    static func title(_ style: Font.TextStyle = .title2) -> Font {
        .system(style, design: .serif, weight: .bold)
    }

    static func body(_ style: Font.TextStyle = .body, weight: Font.Weight = .regular) -> Font {
        .system(style, design: .rounded, weight: weight)
    }

    static func number(_ style: Font.TextStyle = .body) -> Font {
        .system(style, design: .rounded, weight: .heavy).monospacedDigit()
    }

    /// Fixed-size text for labels drawn inside the cave scene, where layout is geometric.
    static func scene(_ size: CGFloat, weight: Font.Weight = .heavy) -> Font {
        .system(size: size, weight: weight, design: .rounded).monospacedDigit()
    }
}
