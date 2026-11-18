//
//  GoalCatalog.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import Foundation

enum GoalCatalog {
    static let all: [VaultGoal] = [
        VaultGoal(
            id: "first-treasure",
            title: "First Treasure",
            detail: "Place your first item on a pedestal.",
            metric: .itemsPlaced,
            target: 1,
            reward: 25
        ),
        VaultGoal(
            id: "taking-shape",
            title: "Taking Shape",
            detail: "Have 3 items standing in the vault.",
            metric: .itemsPlaced,
            target: 3,
            reward: 80
        ),
        VaultGoal(
            id: "steady-trickle",
            title: "Steady Trickle",
            detail: "Reach an income of 5 coins per second.",
            metric: .incomePerSecond,
            target: 5,
            reward: 200
        ),
        VaultGoal(
            id: "night-watch",
            title: "Night Watch",
            detail: "Repel 10 thieves.",
            metric: .thievesRepelled,
            target: 10,
            reward: 400
        ),
        VaultGoal(
            id: "on-a-roll",
            title: "On a Roll",
            detail: "Defeat 10 monsters in a row in one raid.",
            metric: .bestCombo,
            target: 10,
            reward: 500
        ),
        VaultGoal(
            id: "deeper-chambers",
            title: "Deeper Chambers",
            detail: "Open 6 pedestals.",
            metric: .pedestalsOpen,
            target: 6,
            reward: 600
        ),
        VaultGoal(
            id: "polished",
            title: "Polished",
            detail: "Upgrade any item to level 5.",
            metric: .highestItemLevel,
            target: 5,
            reward: 750
        ),
        VaultGoal(
            id: "kingslayer",
            title: "Kingslayer",
            detail: "Defeat the Bone King.",
            metric: .bossesDefeated,
            target: 1,
            reward: 1_500
        ),
        VaultGoal(
            id: "gilded-den",
            title: "A Den Worth Guarding",
            detail: "Reach 45 prestige.",
            metric: .prestige,
            target: 45,
            reward: 2_000
        ),
        VaultGoal(
            id: "golden-stream",
            title: "Golden Stream",
            detail: "Reach an income of 100 coins per second.",
            metric: .incomePerSecond,
            target: 100,
            reward: 6_000
        ),
        VaultGoal(
            id: "iron-gate",
            title: "Iron Gate",
            detail: "Win 3 raids without losing a single coin.",
            metric: .flawlessRaids,
            target: 3,
            reward: 8_000
        ),
        VaultGoal(
            id: "unbroken-chain",
            title: "Unbroken Chain",
            detail: "Defeat 25 monsters in a row in one raid.",
            metric: .bestCombo,
            target: 25,
            reward: 20_000
        ),
        VaultGoal(
            id: "tiger-awakens",
            title: "The Tiger Awakens",
            detail: "Place a Tiger Statue.",
            metric: .owns(.tigerStatue),
            target: 1,
            reward: 30_000
        ),
        VaultGoal(
            id: "keeper-of-millions",
            title: "Keeper of Millions",
            detail: "Earn 1,000,000 coins in total.",
            metric: .lifetimeCoins,
            target: 1_000_000,
            reward: 100_000
        ),
        VaultGoal(
            id: "legend-of-the-gate",
            title: "Legend of the Gate",
            detail: "Repel 150 thieves.",
            metric: .thievesRepelled,
            target: 150,
            reward: 120_000
        ),
        VaultGoal(
            id: "grand-hall",
            title: "Grand Hall",
            detail: "Open all 12 pedestals.",
            metric: .pedestalsOpen,
            target: 12,
            reward: 250_000
        ),
        VaultGoal(
            id: "crowned",
            title: "Crowned",
            detail: "Place a Royal Crown.",
            metric: .owns(.crownPedestal),
            target: 1,
            reward: 400_000
        )
    ]
}
