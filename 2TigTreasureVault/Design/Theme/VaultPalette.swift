//
//  VaultPalette.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

/// Warm cave tones, gold for wealth, cold blue only for thieves.
enum VaultPalette {
    // Cave
    static let caveDeep = Color(hex: 0x100810)
    static let caveShadow = Color(hex: 0x1C0F18)
    static let caveRock = Color(hex: 0x2E1A26)
    static let caveRockLight = Color(hex: 0x4A2C38)
    static let caveFloor = Color(hex: 0x3B222B)

    // Surfaces
    static let panel = Color(hex: 0x24141C)
    static let panelRaised = Color(hex: 0x33202A)
    static let panelStroke = Color(hex: 0xF6C445, opacity: 0.2)

    // Gold and fire
    static let gold = Color(hex: 0xF6C445)
    static let goldLight = Color(hex: 0xFFE9A8)
    static let goldDeep = Color(hex: 0xB9791A)
    static let ember = Color(hex: 0xFF8B3D)
    static let emberDeep = Color(hex: 0xD9481C)

    // Meanings
    static let beauty = Color(hex: 0xFF8FB1)
    static let safety = Color(hex: 0x5ED6A8)
    static let danger = Color(hex: 0xFF5A4F)
    static let spectral = Color(hex: 0x58B9FF)
    static let spectralDeep = Color(hex: 0x1D5E9F)

    // Stone
    static let stone = Color(hex: 0x6E6470)
    static let stoneLight = Color(hex: 0x9A8F9C)
    static let stoneDark = Color(hex: 0x443B47)

    // Text
    static let textPrimary = Color(hex: 0xFFF3DA)
    static let textSecondary = Color(hex: 0xCDB69C)
    static let textMuted = Color(hex: 0xA08A79)
    static let textOnGold = Color(hex: 0x2A1608)

    static let goldGradient = LinearGradient(
        colors: [goldLight, gold, goldDeep],
        startPoint: .top,
        endPoint: .bottom
    )
}

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}
