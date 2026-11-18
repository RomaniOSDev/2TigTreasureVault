//
//  CaveSceneView.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

/// Where each pedestal stands, as fractions of the playfield. Order is the order they are dug out.
enum SlotLayout {
    struct Spot {
        let x: CGFloat
        let y: CGFloat
        /// Back rows are drawn smaller to suggest depth.
        let scale: CGFloat
    }

    static let spots: [Spot] = [
        Spot(x: 0.25, y: 0.63, scale: 1),
        Spot(x: 0.5, y: 0.63, scale: 1),
        Spot(x: 0.75, y: 0.63, scale: 1),
        Spot(x: 0.38, y: 0.385, scale: 0.88),
        Spot(x: 0.62, y: 0.385, scale: 0.88),
        Spot(x: 0.3, y: 0.885, scale: 1.1),
        Spot(x: 0.14, y: 0.385, scale: 0.88),
        Spot(x: 0.86, y: 0.385, scale: 0.88),
        Spot(x: 0.7, y: 0.885, scale: 1.1),
        Spot(x: 0.25, y: 0.14, scale: 0.78),
        Spot(x: 0.5, y: 0.14, scale: 0.78),
        Spot(x: 0.75, y: 0.14, scale: 0.78)
    ]
}

/// Lays the pedestals out on the cave floor.
struct CaveSceneView: View {
    @Environment(VaultStore.self) private var store
    let onTapSlot: (Int) -> Void

    var body: some View {
        GeometryReader { geo in
            let unit = min(geo.size.width / 4.3, geo.size.height / 5.5)

            ZStack {
                ForEach(Array(store.slots.enumerated()), id: \.offset) { index, slot in
                    if SlotLayout.spots.indices.contains(index) {
                        let spot = SlotLayout.spots[index]

                        VaultSlotView(
                            content: content(for: slot, at: index),
                            number: index + 1,
                            unit: unit * spot.scale
                        ) {
                            onTapSlot(index)
                        }
                        .position(x: spot.x * geo.size.width, y: spot.y * geo.size.height)
                        .zIndex(Double(spot.y))
                    }
                }
            }
        }
    }

    private func content(for slot: VaultSlot, at index: Int) -> VaultSlotView.Content {
        guard slot.isUnlocked else {
            let isNext = store.nextLockedSlot == index
            return .locked(cost: isNext ? Economy.unlockCost(forSlot: index) : nil)
        }
        guard let item = slot.item else {
            return .empty
        }
        let canUpgrade = item.level < Economy.maxLevel && store.canAfford(Economy.upgradeCost(for: item))
        return .item(item, canUpgrade: canUpgrade)
    }
}
