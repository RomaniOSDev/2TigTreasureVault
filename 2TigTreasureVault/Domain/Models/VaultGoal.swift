//
//  VaultGoal.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import Foundation

enum GoalMetric {
    case itemsPlaced
    case incomePerSecond
    case pedestalsOpen
    case prestige
    case thievesRepelled
    case flawlessRaids
    case bestCombo
    case bossesDefeated
    case lifetimeCoins
    case highestItemLevel
    case owns(VaultItemKind)
}

/// A one-time objective with a coin reward.
struct VaultGoal: Identifiable {
    let id: String
    let title: String
    let detail: String
    let metric: GoalMetric
    let target: Double
    let reward: Double
}
