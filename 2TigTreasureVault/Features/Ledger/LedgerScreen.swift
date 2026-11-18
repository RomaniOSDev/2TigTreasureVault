//
//  LedgerScreen.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

/// Rank, vault scores, raid history and the ladder of ranks.
struct LedgerScreen: View {
    @Environment(VaultStore.self) private var store

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        VaultScrollScreen(title: "Ledger", subtitle: "Everything your vault has to show for itself.") {
            RankCard(
                rank: store.rank,
                prestige: store.prestige,
                progress: store.rankProgress
            )

            SectionHeading(text: "Vault")
            LazyVGrid(columns: columns, spacing: 12) {
                StatTile(
                    title: "Income per second",
                    value: CoinFormatter.rate(store.incomePerSecond),
                    symbol: StatSymbol.income,
                    tint: VaultPalette.gold
                )
                StatTile(
                    title: "Prestige",
                    value: "\(store.prestige)",
                    symbol: "crown.fill",
                    tint: VaultPalette.goldLight
                )
                StatTile(
                    title: "Beauty",
                    value: "\(store.beauty)",
                    symbol: StatSymbol.beauty,
                    tint: VaultPalette.beauty
                )
                StatTile(
                    title: "Safety",
                    value: "\(store.safety)",
                    symbol: StatSymbol.safety,
                    tint: VaultPalette.safety
                )
                StatTile(
                    title: "Tap power in raids",
                    value: "\(store.tapDamage)",
                    symbol: "hand.tap.fill",
                    tint: VaultPalette.safety
                )
                StatTile(
                    title: "Loot kept from thieves",
                    value: "\(store.lootProtectionPercent)%",
                    symbol: "lock.shield.fill",
                    tint: VaultPalette.safety
                )
            }

            SectionHeading(text: "History")
            LazyVGrid(columns: columns, spacing: 12) {
                StatTile(
                    title: "Coins earned",
                    value: CoinFormatter.short(store.lifetimeCoins),
                    symbol: "sum",
                    tint: VaultPalette.gold
                )
                StatTile(
                    title: "Raids faced",
                    value: "\(store.stats.raidsFaced)",
                    symbol: "flag.fill",
                    tint: VaultPalette.spectral
                )
                StatTile(
                    title: "Flawless defenses",
                    value: "\(store.stats.flawlessRaids)",
                    symbol: "shield.lefthalf.filled",
                    tint: VaultPalette.spectral
                )
                StatTile(
                    title: "Monsters repelled",
                    value: "\(store.stats.thievesRepelled)",
                    symbol: "figure.walk.departure",
                    tint: VaultPalette.spectral
                )
                StatTile(
                    title: "Best combo",
                    value: "×\(store.stats.bestCombo)",
                    symbol: "bolt.fill",
                    tint: VaultPalette.gold
                )
                StatTile(
                    title: "Bone Kings defeated",
                    value: "\(store.stats.bossesDefeated)",
                    symbol: "crown.fill",
                    tint: VaultPalette.danger
                )
                StatTile(
                    title: "Coins lost to thieves",
                    value: CoinFormatter.short(store.stats.coinsStolen),
                    symbol: "arrow.down.right",
                    tint: VaultPalette.danger
                )
            }

            SectionHeading(text: "Bestiary")
            BestiarySection(raidsFaced: store.stats.raidsFaced)

            SectionHeading(text: "Ranks")
            VStack(spacing: 0) {
                ForEach(VaultRank.allCases) { rank in
                    RankLadderRow(
                        rank: rank,
                        isCurrent: rank == store.rank,
                        isReached: rank <= store.bestRank
                    )
                    if rank != VaultRank.allCases.last {
                        Divider().overlay(VaultPalette.panelStroke)
                    }
                }
            }
            .vaultPanel(padding: 4)
        }
    }
}

private struct RankCard: View {
    let rank: VaultRank
    let prestige: Int
    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current rank")
                        .font(VaultFont.body(.footnote, weight: .semibold))
                        .foregroundStyle(VaultPalette.textMuted)
                    Text(rank.name)
                        .font(VaultFont.title(.title))
                        .foregroundStyle(VaultPalette.gold)
                }
                Spacer(minLength: 8)
                StatChip(
                    symbol: StatSymbol.income,
                    text: "+\(rank.incomeBonusPercent)%",
                    tint: VaultPalette.gold,
                    accessibilityName: "Income bonus"
                )
            }

            if let next = rank.next {
                VStack(alignment: .leading, spacing: 8) {
                    VaultProgressBar(value: progress)
                    Text("\(max(0, next.threshold - prestige)) more prestige to become a \(next.name).")
                        .font(VaultFont.body(.footnote))
                        .foregroundStyle(VaultPalette.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } else {
                Text("There is no finer vault anywhere under the mountain.")
                    .font(VaultFont.body(.footnote))
                    .foregroundStyle(VaultPalette.textSecondary)
            }

            Text("Prestige is beauty plus safety. Each rank adds 15% to all income.")
                .font(VaultFont.body(.footnote))
                .foregroundStyle(VaultPalette.textMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .vaultPanel(padding: 18, stroke: VaultPalette.gold.opacity(0.45))
    }
}

private struct StatTile: View {
    let title: String
    let value: String
    let symbol: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: symbol)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(tint)
                .frame(height: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(VaultFont.number(.title3))
                    .foregroundStyle(VaultPalette.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text(title)
                    .font(VaultFont.body(.caption, weight: .medium))
                    .foregroundStyle(VaultPalette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 78, alignment: .topLeading)
        .vaultPanel(padding: 14)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title): \(value)")
    }
}

private struct RankLadderRow: View {
    let rank: VaultRank
    let isCurrent: Bool
    let isReached: Bool

    private var unlockText: String {
        let names = ItemCatalog.unlocks(at: rank).map(\.name)
        guard !names.isEmpty else { return "+\(rank.incomeBonusPercent)% income" }
        return "+\(rank.incomeBonusPercent)% income · " + names.joined(separator: ", ")
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isReached ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(isReached ? VaultPalette.gold : VaultPalette.textMuted)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(rank.name)
                    .font(VaultFont.title(.subheadline))
                    .foregroundStyle(isCurrent ? VaultPalette.gold : VaultPalette.textPrimary)
                Text(unlockText)
                    .font(VaultFont.body(.caption))
                    .foregroundStyle(VaultPalette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            Text("\(rank.threshold)")
                .font(VaultFont.number(.subheadline))
                .foregroundStyle(VaultPalette.textSecondary)
                .accessibilityLabel("\(rank.threshold) prestige")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
        .accessibilityValue(isCurrent ? "Current rank" : (isReached ? "Reached" : "Not reached"))
    }
}

#Preview {
    LedgerScreen()
        .environment(VaultStore())
}
