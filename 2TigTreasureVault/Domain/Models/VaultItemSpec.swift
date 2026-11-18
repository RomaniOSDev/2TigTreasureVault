//
//  VaultItemSpec.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import Foundation

/// Static balance data for one kind of item.
struct VaultItemSpec: Identifiable {
    let kind: VaultItemKind
    let name: String
    let blurb: String
    let baseCost: Double
    /// Coins per second at level 1.
    let baseIncome: Double
    let baseBeauty: Int
    let baseSafety: Int
    let requiredRank: VaultRank

    var id: VaultItemKind { kind }

    func income(atLevel level: Int) -> Double {
        baseIncome * Double(level) * pow(1.08, Double(level - 1))
    }

    func beauty(atLevel level: Int) -> Int {
        baseBeauty + baseBeauty * (level - 1) / 3
    }

    func safety(atLevel level: Int) -> Int {
        baseSafety + baseSafety * (level - 1) / 2
    }
}
