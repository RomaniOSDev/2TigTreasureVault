//
//  VaultHUDView.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

/// Coins, income, the two vault scores and progress toward the next rank.
struct VaultHUDView: View {
    @Environment(VaultStore.self) private var store

    private var incomeLine: String {
        store.isUnderSiege
            ? "Income on hold"
            : "+\(CoinFormatter.rate(store.incomePerSecond)) per second"
    }

    private var rankCaption: String {
        if let next = store.rank.next {
            "\(store.prestige) / \(next.threshold) prestige"
        } else {
            "Highest rank"
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        CoinIcon(size: 26)
                        Text(CoinFormatter.short(store.coins))
                            .font(VaultFont.number(.title))
                            .foregroundStyle(VaultPalette.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(CoinFormatter.short(store.coins)) coins")

                    Text(incomeLine)
                        .font(VaultFont.body(.footnote, weight: .semibold))
                        .foregroundStyle(store.isUnderSiege ? VaultPalette.spectral : VaultPalette.gold)
                }

                Spacer(minLength: 0)

                VStack(alignment: .trailing, spacing: 6) {
                    StatChip(
                        symbol: StatSymbol.beauty,
                        text: "\(store.beauty)",
                        tint: VaultPalette.beauty,
                        accessibilityName: "Beauty"
                    )
                    StatChip(
                        symbol: StatSymbol.safety,
                        text: "\(store.safety)",
                        tint: VaultPalette.safety,
                        accessibilityName: "Safety"
                    )
                }
            }

            VStack(spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(store.rank.name)
                        .font(VaultFont.title(.subheadline))
                        .foregroundStyle(VaultPalette.textPrimary)
                    Spacer(minLength: 8)
                    Text(rankCaption)
                        .font(VaultFont.body(.caption, weight: .medium))
                        .foregroundStyle(VaultPalette.textSecondary)
                }
                VaultProgressBar(value: store.rankProgress, height: 6)
            }
            .accessibilityElement(children: .combine)
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: VaultMetrics.panelRadius, style: .continuous)
                .fill(VaultPalette.panel.opacity(0.9))
        }
        .overlay {
            RoundedRectangle(cornerRadius: VaultMetrics.panelRadius, style: .continuous)
                .strokeBorder(VaultPalette.panelStroke, lineWidth: 1)
        }
    }
}
