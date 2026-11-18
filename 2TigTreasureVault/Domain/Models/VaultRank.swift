//
//  VaultRank.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import Foundation

/// How renowned the vault is. Driven by prestige (beauty + safety).
enum VaultRank: Int, CaseIterable, Comparable, Identifiable {
    case dustyHollow
    case hiddenCache
    case gildedDen
    case royalVault
    case tigersHoard
    case legendaryTrove

    var id: Int { rawValue }

    var name: String {
        switch self {
        case .dustyHollow: "Dusty Hollow"
        case .hiddenCache: "Hidden Cache"
        case .gildedDen: "Gilded Den"
        case .royalVault: "Royal Vault"
        case .tigersHoard: "Tiger's Hoard"
        case .legendaryTrove: "Legendary Trove"
        }
    }

    /// Prestige needed to hold this rank.
    var threshold: Int {
        switch self {
        case .dustyHollow: 0
        case .hiddenCache: 12
        case .gildedDen: 45
        case .royalVault: 120
        case .tigersHoard: 280
        case .legendaryTrove: 600
        }
    }

    /// Every rank adds 15% to all income.
    var incomeMultiplier: Double {
        1 + 0.15 * Double(rawValue)
    }

    var incomeBonusPercent: Int {
        15 * rawValue
    }

    var next: VaultRank? {
        VaultRank(rawValue: rawValue + 1)
    }

    static func rank(forPrestige prestige: Int) -> VaultRank {
        allCases.last { prestige >= $0.threshold } ?? .dustyHollow
    }

    static func < (lhs: VaultRank, rhs: VaultRank) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
