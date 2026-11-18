//
//  Economy.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import Foundation

/// Pure balance rules. No state lives here.
enum Economy {
    static let slotCount = 12
    static let initiallyOpenSlots = 4
    static let startingCoins: Double = 25
    static let maxLevel = 20

    static let firstRaidDelay: Double = 30
    /// Quiet time between raids. Picked at random so raids never feel like clockwork.
    static let raidInterval: ClosedRange<Double> = 40...65
    /// Thieves only take notice once the vault has earned this much and holds a couple of treasures.
    static let raidUnlockLifetimeCoins: Double = 60
    static let raidUnlockItems = 2

    /// A gap this long between ticks counts as time away.
    static let awayThreshold: Double = 60
    static let awayRate = 0.5
    static let awayCap: Double = 6 * 3_600

    static let refundRate = 0.5

    private static let slotUnlockCosts: [Double] = [
        0, 0, 0, 0,
        250, 900, 3_500, 12_000,
        40_000, 140_000, 500_000, 1_800_000
    ]

    // MARK: Items

    static func income(of item: PlacedItem) -> Double {
        ItemCatalog.spec(for: item.kind).income(atLevel: item.level)
    }

    static func beauty(of item: PlacedItem) -> Int {
        ItemCatalog.spec(for: item.kind).beauty(atLevel: item.level)
    }

    static func safety(of item: PlacedItem) -> Int {
        ItemCatalog.spec(for: item.kind).safety(atLevel: item.level)
    }

    /// Each copy of the same item costs 25% more than the last.
    static func purchaseCost(for kind: VaultItemKind, owned: Int) -> Double {
        (ItemCatalog.spec(for: kind).baseCost * pow(1.25, Double(owned))).rounded()
    }

    static func upgradeCost(for item: PlacedItem) -> Double {
        (ItemCatalog.spec(for: item.kind).baseCost * pow(1.45, Double(item.level))).rounded()
    }

    static func refund(for item: PlacedItem) -> Double {
        (item.invested * refundRate).rounded(.down)
    }

    // MARK: Whole vault

    static func income(of slots: [VaultSlot]) -> Double {
        slots.compactMap(\.item).reduce(0) { $0 + income(of: $1) }
    }

    static func beauty(of slots: [VaultSlot]) -> Int {
        slots.compactMap(\.item).reduce(0) { $0 + beauty(of: $1) }
    }

    static func safety(of slots: [VaultSlot]) -> Int {
        slots.compactMap(\.item).reduce(0) { $0 + safety(of: $1) }
    }

    static func unlockCost(forSlot index: Int) -> Double {
        guard slotUnlockCosts.indices.contains(index) else { return 0 }
        return slotUnlockCosts[index]
    }
}
