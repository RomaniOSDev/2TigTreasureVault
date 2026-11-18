//
//  ItemDetailSheet.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

/// Upgrade or remove the item standing on a pedestal.
struct ItemDetailSheet: View {
    let slotIndex: Int

    @Environment(VaultStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var isConfirmingRemoval = false

    private var item: PlacedItem? {
        store.slots.indices.contains(slotIndex) ? store.slots[slotIndex].item : nil
    }

    var body: some View {
        Group {
            if let item {
                detail(for: item, spec: ItemCatalog.spec(for: item.kind))
            } else {
                // The item was just removed; the sheet is on its way out.
                VaultBackgroundView()
            }
        }
        .presentationDetents([.large])
    }

    private func detail(for item: PlacedItem, spec: VaultItemSpec) -> some View {
        let isMaxed = item.level >= Economy.maxLevel
        let upgradeCost = Economy.upgradeCost(for: item)
        let canAfford = store.canAfford(upgradeCost)
        let refund = Economy.refund(for: item)

        return SheetScaffold(title: spec.name, subtitle: "Level \(item.level) of \(Economy.maxLevel)") {
            ItemArtView(kind: item.kind)
                .frame(height: 170)
                .frame(maxWidth: .infinity)
                .vaultPanel(padding: 12)

            Text(spec.blurb)
                .font(VaultFont.body(.body))
                .foregroundStyle(VaultPalette.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            if let power = RaidPower.granted(by: item.kind) {
                VStack(alignment: .leading, spacing: 4) {
                    RaidPowerNote(power: power)
                    Text(power.effect)
                        .font(VaultFont.body(.footnote))
                        .foregroundStyle(VaultPalette.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .vaultPanel(padding: 14, stroke: power.tint.opacity(0.4))
            }

            VStack(spacing: 12) {
                if spec.baseIncome > 0 {
                    UpgradeStatRow(
                        symbol: StatSymbol.income,
                        title: "Income per second",
                        tint: VaultPalette.gold,
                        current: CoinFormatter.rate(spec.income(atLevel: item.level)),
                        next: isMaxed ? nil : CoinFormatter.rate(spec.income(atLevel: item.level + 1))
                    )
                }
                if spec.baseBeauty > 0 {
                    UpgradeStatRow(
                        symbol: StatSymbol.beauty,
                        title: "Beauty",
                        tint: VaultPalette.beauty,
                        current: "\(spec.beauty(atLevel: item.level))",
                        next: isMaxed ? nil : "\(spec.beauty(atLevel: item.level + 1))"
                    )
                }
                if spec.baseSafety > 0 {
                    UpgradeStatRow(
                        symbol: StatSymbol.safety,
                        title: "Safety",
                        tint: VaultPalette.safety,
                        current: "\(spec.safety(atLevel: item.level))",
                        next: isMaxed ? nil : "\(spec.safety(atLevel: item.level + 1))"
                    )
                }
            }
            .vaultPanel()

            if isMaxed {
                Label("Fully upgraded", systemImage: "checkmark.seal.fill")
                    .font(VaultFont.body(.headline, weight: .bold))
                    .foregroundStyle(VaultPalette.gold)
                    .frame(maxWidth: .infinity, minHeight: 52)
            } else {
                VStack(spacing: 8) {
                    Button {
                        if store.upgrade(at: slotIndex) {
                            Haptics.success()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text("Upgrade")
                            CoinLabel(amount: upgradeCost, style: .headline, iconSize: 18)
                        }
                    }
                    .buttonStyle(GoldButtonStyle())
                    .disabled(!canAfford)
                    .accessibilityLabel("Upgrade for \(CoinFormatter.short(upgradeCost)) coins")

                    if !canAfford {
                        Text("You need \(CoinFormatter.short(upgradeCost - store.coins + 1)) more coins.")
                            .font(VaultFont.body(.footnote))
                            .foregroundStyle(VaultPalette.textMuted)
                    }
                }
            }

            Button("Remove from vault") {
                isConfirmingRemoval = true
            }
            .buttonStyle(OutlineButtonStyle(tint: VaultPalette.danger))
            .confirmationDialog(
                "Remove \(spec.name)?",
                isPresented: $isConfirmingRemoval,
                titleVisibility: .visible
            ) {
                Button("Remove and take \(CoinFormatter.short(refund)) coins", role: .destructive) {
                    store.remove(at: slotIndex)
                    dismiss()
                }
                Button("Keep it", role: .cancel) {}
            } message: {
                Text("You get back half of what you spent on it. Its upgrades are lost.")
            }
        }
    }
}

private struct UpgradeStatRow: View {
    let symbol: String
    let title: String
    let tint: Color
    let current: String
    /// `nil` once the item is at its top level.
    let next: String?

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(tint)
                .frame(width: 24)

            Text(title)
                .font(VaultFont.body(.subheadline, weight: .medium))
                .foregroundStyle(VaultPalette.textSecondary)

            Spacer(minLength: 8)

            Text(current)
                .font(VaultFont.number(.subheadline))
                .foregroundStyle(VaultPalette.textPrimary)

            if let next {
                Image(systemName: "arrow.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(VaultPalette.textMuted)
                Text(next)
                    .font(VaultFont.number(.subheadline))
                    .foregroundStyle(tint)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(next.map { "\(title): \(current), \($0) after upgrade" } ?? "\(title): \(current)")
    }
}
