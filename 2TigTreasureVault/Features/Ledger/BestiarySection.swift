//
//  BestiarySection.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

/// Every monster that raids the vault. Ones the keeper has not met yet stay in shadow.
struct BestiarySection: View {
    let raidsFaced: Int

    /// Slimelings only ever come out of a slime, so they do not get a row of their own.
    private let kinds = ThiefKind.allCases.filter { $0 != .slimeling }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(kinds) { kind in
                BestiaryRow(kind: kind, isMet: raidsFaced >= kind.firstRaid)
                if kind != kinds.last {
                    Divider().overlay(VaultPalette.panelStroke)
                }
            }
        }
        .vaultPanel(padding: 4)
    }
}

private struct BestiaryRow: View {
    let kind: ThiefKind
    let isMet: Bool

    private var detail: String {
        if isMet { return kind.tip }
        return kind.isBoss
            ? "Leads every \(RaidPlanner.bossEvery)th raid."
            : "First seen in raid \(kind.firstRaid)."
    }

    var body: some View {
        HStack(spacing: 12) {
            ThiefArt(kind: kind)
                .frame(width: 52, height: 52)
                // An unmet monster is only a dark outline.
                .brightness(isMet ? 0 : -1)
                .opacity(isMet ? 1 : 0.55)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(isMet ? kind.displayName : "Unknown")
                    .font(VaultFont.title(.subheadline))
                    .foregroundStyle(isMet ? VaultPalette.textPrimary : VaultPalette.textMuted)
                Text(detail)
                    .font(VaultFont.body(.caption))
                    .foregroundStyle(VaultPalette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ZStack {
        VaultBackgroundView()
        BestiarySection(raidsFaced: 4).padding()
    }
}
