//
//  BuildSheet.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

/// Catalog of everything that can go on an empty pedestal.
struct BuildSheet: View {
    let slotIndex: Int

    @Environment(VaultStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        SheetScaffold(title: "Choose a treasure", subtitle: "Pedestal \(slotIndex + 1) is waiting.") {
            HStack {
                Text("Your coins")
                    .font(VaultFont.body(.subheadline, weight: .medium))
                    .foregroundStyle(VaultPalette.textSecondary)
                Spacer()
                CoinLabel(amount: store.coins, style: .headline, iconSize: 18)
                    .foregroundStyle(VaultPalette.gold)
            }
            .vaultPanel(padding: 14)

            ForEach(ItemCatalog.all) { spec in
                let cost = store.purchaseCost(for: spec.kind)

                ItemOfferRow(
                    spec: spec,
                    cost: cost,
                    isAvailable: store.isAvailable(spec),
                    canAfford: store.canAfford(cost)
                ) {
                    if store.place(spec.kind, at: slotIndex) {
                        Haptics.success()
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.large])
    }
}

private struct ItemOfferRow: View {
    let spec: VaultItemSpec
    let cost: Double
    let isAvailable: Bool
    let canAfford: Bool
    let onPlace: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ItemArtView(kind: spec.kind)
                .frame(width: 76, height: 76)
                .saturation(isAvailable ? 1 : 0)
                .opacity(isAvailable ? 1 : 0.45)
                .background(VaultPalette.panelRaised, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(spec.name)
                        .font(VaultFont.title(.headline))
                        .foregroundStyle(VaultPalette.textPrimary)
                    Text(spec.blurb)
                        .font(VaultFont.body(.footnote))
                        .foregroundStyle(VaultPalette.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                ItemStatChips(spec: spec, level: 1)

                if let power = RaidPower.granted(by: spec.kind) {
                    RaidPowerNote(power: power)
                }

                if isAvailable {
                    Button(action: onPlace) {
                        HStack(spacing: 8) {
                            Text("Place")
                            CoinLabel(amount: cost)
                        }
                    }
                    .buttonStyle(GoldButtonStyle(isCompact: true))
                    .disabled(!canAfford)
                    .accessibilityLabel("Place \(spec.name) for \(CoinFormatter.short(cost)) coins")
                } else {
                    Label("Unlocks at \(spec.requiredRank.name)", systemImage: "lock.fill")
                        .font(VaultFont.body(.footnote, weight: .semibold))
                        .foregroundStyle(VaultPalette.textMuted)
                }
            }

            Spacer(minLength: 0)
        }
        .vaultPanel(padding: 14)
    }
}

/// Income, beauty and safety chips for an item at a given level.
struct ItemStatChips: View {
    let spec: VaultItemSpec
    let level: Int

    var body: some View {
        HStack(spacing: 6) {
            if spec.baseIncome > 0 {
                StatChip(
                    symbol: StatSymbol.income,
                    text: "\(CoinFormatter.rate(spec.income(atLevel: level)))/s",
                    tint: VaultPalette.gold,
                    accessibilityName: "Income per second"
                )
            }
            if spec.baseBeauty > 0 {
                StatChip(
                    symbol: StatSymbol.beauty,
                    text: "\(spec.beauty(atLevel: level))",
                    tint: VaultPalette.beauty,
                    accessibilityName: "Beauty"
                )
            }
            if spec.baseSafety > 0 {
                StatChip(
                    symbol: StatSymbol.safety,
                    text: "\(spec.safety(atLevel: level))",
                    tint: VaultPalette.safety,
                    accessibilityName: "Safety"
                )
            }
        }
    }
}

#Preview {
    Color.black
        .sheet(isPresented: .constant(true)) {
            BuildSheet(slotIndex: 0)
                .environment(VaultStore())
        }
}
