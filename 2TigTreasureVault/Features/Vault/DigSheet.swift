//
//  DigSheet.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

/// Pay to clear the next buried pedestal.
struct DigSheet: View {
    @Environment(VaultStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        let cost = store.nextLockedSlot.map { Economy.unlockCost(forSlot: $0) } ?? 0
        let canAfford = store.canAfford(cost)

        SheetScaffold(
            title: "Dig out a pedestal",
            subtitle: "\(store.openPedestalCount) of \(Economy.slotCount) pedestals are open."
        ) {
            PedestalArt(look: .rubble)
                .frame(width: 180, height: 72)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .accessibilityHidden(true)

            Text("Clear the rubble to make room for one more treasure. Pedestals are dug out one at a time, from the front of the cave to the back.")
                .font(VaultFont.body(.body))
                .foregroundStyle(VaultPalette.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 8) {
                Button {
                    if store.unlockNextSlot() {
                        Haptics.success()
                        dismiss()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Text("Dig")
                        CoinLabel(amount: cost, style: .headline, iconSize: 18)
                    }
                }
                .buttonStyle(GoldButtonStyle())
                .disabled(!canAfford)
                .accessibilityLabel("Dig for \(CoinFormatter.short(cost)) coins")

                if !canAfford {
                    Text("You need \(CoinFormatter.short(cost - store.coins + 1)) more coins.")
                        .font(VaultFont.body(.footnote))
                        .foregroundStyle(VaultPalette.textMuted)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
