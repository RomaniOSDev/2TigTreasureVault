//
//  ItemCatalog.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import Foundation

enum ItemCatalog {
    static let all: [VaultItemSpec] = [
        VaultItemSpec(
            kind: .woodenChest,
            name: "Oak Chest",
            blurb: "A sturdy chest that slowly fills with coins.",
            baseCost: 10,
            baseIncome: 1,
            baseBeauty: 1,
            baseSafety: 0,
            requiredRank: .dustyHollow
        ),
        VaultItemSpec(
            kind: .torch,
            name: "Cave Torch",
            blurb: "Light keeps the shadows, and thieves, at bay.",
            baseCost: 35,
            baseIncome: 0,
            baseBeauty: 1,
            baseSafety: 2,
            requiredRank: .dustyHollow
        ),
        VaultItemSpec(
            kind: .coinPile,
            name: "Coin Pile",
            blurb: "Loose gold that somehow keeps growing.",
            baseCost: 120,
            baseIncome: 5,
            baseBeauty: 2,
            baseSafety: 0,
            requiredRank: .dustyHollow
        ),
        VaultItemSpec(
            kind: .brazier,
            name: "Fire Brazier",
            blurb: "A roaring fire that guards a wide circle.",
            baseCost: 700,
            baseIncome: 0,
            baseBeauty: 3,
            baseSafety: 5,
            requiredRank: .hiddenCache
        ),
        VaultItemSpec(
            kind: .goldChest,
            name: "Gilded Chest",
            blurb: "Overflowing, and proud of it.",
            baseCost: 1_400,
            baseIncome: 28,
            baseBeauty: 4,
            baseSafety: 0,
            requiredRank: .hiddenCache
        ),
        VaultItemSpec(
            kind: .guardianStatue,
            name: "Stone Guardian",
            blurb: "It never blinks. Thieves hate that.",
            baseCost: 6_000,
            baseIncome: 0,
            baseBeauty: 6,
            baseSafety: 12,
            requiredRank: .gildedDen
        ),
        VaultItemSpec(
            kind: .gemCluster,
            name: "Gem Cluster",
            blurb: "Crystals that hum with quiet wealth.",
            baseCost: 12_000,
            baseIncome: 150,
            baseBeauty: 9,
            baseSafety: 0,
            requiredRank: .gildedDen
        ),
        VaultItemSpec(
            kind: .tigerStatue,
            name: "Tiger Statue",
            blurb: "A golden tiger whose magic draws coins from the dark.",
            baseCost: 90_000,
            baseIncome: 800,
            baseBeauty: 16,
            baseSafety: 6,
            requiredRank: .royalVault
        ),
        VaultItemSpec(
            kind: .crownPedestal,
            name: "Royal Crown",
            blurb: "The centerpiece every vault dreams of.",
            baseCost: 750_000,
            baseIncome: 5_000,
            baseBeauty: 30,
            baseSafety: 0,
            requiredRank: .tigersHoard
        )
    ]

    private static let byKind: [VaultItemKind: VaultItemSpec] = Dictionary(
        uniqueKeysWithValues: all.map { ($0.kind, $0) }
    )

    static func spec(for kind: VaultItemKind) -> VaultItemSpec {
        byKind[kind] ?? all[0]
    }

    static func unlocks(at rank: VaultRank) -> [VaultItemSpec] {
        all.filter { $0.requiredRank == rank }
    }
}
