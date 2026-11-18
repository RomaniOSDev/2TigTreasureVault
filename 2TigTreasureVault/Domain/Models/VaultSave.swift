//
//  VaultSave.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import Foundation

/// Lifetime counters shown in the ledger and used by goals.
struct VaultStats: Codable, Equatable {
    var raidsFaced = 0
    var flawlessRaids = 0
    var thievesRepelled = 0
    var coinsStolen: Double = 0
    var bestCombo = 0
    var bossesDefeated = 0

    init() {}

    /// Counters added after the first release are optional, so older saves keep loading.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        raidsFaced = try container.decodeIfPresent(Int.self, forKey: .raidsFaced) ?? 0
        flawlessRaids = try container.decodeIfPresent(Int.self, forKey: .flawlessRaids) ?? 0
        thievesRepelled = try container.decodeIfPresent(Int.self, forKey: .thievesRepelled) ?? 0
        coinsStolen = try container.decodeIfPresent(Double.self, forKey: .coinsStolen) ?? 0
        bestCombo = try container.decodeIfPresent(Int.self, forKey: .bestCombo) ?? 0
        bossesDefeated = try container.decodeIfPresent(Int.self, forKey: .bossesDefeated) ?? 0
    }
}

/// Snapshot written to disk.
struct VaultSave: Codable {
    var coins: Double
    var lifetimeCoins: Double
    var slots: [VaultSlot]
    var stats: VaultStats
    var claimedGoals: Set<String>
    /// Highest rank ever reached. Item unlocks never go away once earned.
    var bestRank: Int
    var secondsUntilRaid: Double
    var isUnderSiege: Bool
    var lastActive: Date

    static func fresh(now: Date) -> VaultSave {
        let slots = (0..<Economy.slotCount).map { index in
            VaultSlot(isUnlocked: index < Economy.initiallyOpenSlots, item: nil)
        }
        return VaultSave(
            coins: Economy.startingCoins,
            lifetimeCoins: 0,
            slots: slots,
            stats: VaultStats(),
            claimedGoals: [],
            bestRank: 0,
            secondsUntilRaid: Economy.firstRaidDelay,
            isUnderSiege: false,
            lastActive: now
        )
    }
}
