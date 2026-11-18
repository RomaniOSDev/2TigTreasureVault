//
//  CoinLabel.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

/// The coin glyph used next to every amount.
struct CoinIcon: View {
    var size: CGFloat = 18

    var body: some View {
        Circle()
            .fill(VaultPalette.goldGradient)
            .overlay {
                Circle().strokeBorder(VaultPalette.goldDeep, lineWidth: size * 0.09)
            }
            .overlay {
                Circle()
                    .strokeBorder(VaultPalette.goldLight.opacity(0.8), lineWidth: size * 0.07)
                    .padding(size * 0.22)
            }
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}

/// Coin glyph plus a short amount, e.g. "1.25K".
struct CoinLabel: View {
    let amount: Double
    var style: Font.TextStyle = .subheadline
    var iconSize: CGFloat = 16
    var prefix = ""

    var body: some View {
        HStack(spacing: 5) {
            CoinIcon(size: iconSize)
            Text(prefix + CoinFormatter.short(amount))
                .font(VaultFont.number(style))
                .lineLimit(1)
        }
        // An amount is never worth wrapping or truncating.
        .fixedSize()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(prefix)\(CoinFormatter.short(amount)) coins")
    }
}

/// Icon + number chip for beauty, safety and similar stats.
struct StatChip: View {
    let symbol: String
    let text: String
    let tint: Color
    var accessibilityName: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: symbol)
                .font(.caption.weight(.bold))
            Text(text)
                .font(VaultFont.number(.caption))
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(tint.opacity(0.13), in: Capsule())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(accessibilityName) \(text)")
    }
}

enum StatSymbol {
    static let beauty = "sparkles"
    static let safety = "shield.fill"
    static let income = "arrow.up.right"
}
