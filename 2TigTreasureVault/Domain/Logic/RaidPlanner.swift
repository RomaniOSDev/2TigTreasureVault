//
//  RaidPlanner.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import Foundation

/// Raid rules, and the code that turns the vault's current state into a concrete raid.
enum RaidPlanner {
    /// The Bone King leads every raid whose number divides by this.
    static let bossEvery = 5

    // Powers
    static let wardDuration: Double = 3.5
    static let roarKnockback = 0.3
    static let roarStun: Double = 1.2

    // Combo: every kill in a row adds 5% bounty, up to double.
    static let comboStep = 0.05
    static let comboCap = 20

    private static let wavePause: Double = 3.2

    // MARK: Rules

    /// Every 20 safety adds one point of damage to each tap.
    static func tapDamage(safety: Int) -> Int {
        1 + safety / 20
    }

    static func flameDamage(tapDamage: Int) -> Int {
        tapDamage + 1
    }

    /// Share of loot that safety keeps out of thieves' hands, 0...0.7.
    static func mitigation(safety: Int) -> Double {
        min(0.7, Double(safety) / Double(safety + 60))
    }

    /// Price of letting the thieves through without a fight.
    static func toll(coins: Double, safety: Int) -> Double {
        (coins * 0.06 * (1 - mitigation(safety: safety))).rounded(.down)
    }

    /// Bounty multiplier for the `combo`-th kill in a row.
    static func comboMultiplier(_ combo: Int) -> Double {
        1 + comboStep * Double(min(max(combo - 1, 0), comboCap))
    }

    static func isBossRaid(level: Int) -> Bool {
        level % bossEvery == 0
    }

    static func powers(for slots: [VaultSlot]) -> Set<RaidPower> {
        let placed = Set(slots.compactMap { $0.item?.kind })
        return Set(RaidPower.allCases.filter { power in
            power.sources.contains { placed.contains($0) }
        })
    }

    static func hitPoints(for kind: ThiefKind, level: Int) -> Int {
        // Monsters stop getting tougher after a while; the keeper's taps do not.
        let tier = min(level, 25) - 1
        switch kind {
        case .skeleton, .slime: return kind.baseHP + tier / 4
        case .bat, .slimeling: return kind.baseHP + tier / 10
        case .runner: return kind.baseHP + tier / 6
        case .brute: return kind.baseHP + tier / 3
        case .ghost: return kind.baseHP + tier / 5
        case .boneKing: return kind.baseHP + 6 * min(level / bossEvery, 6)
        }
    }

    // MARK: Plan

    static func makePlan(
        level: Int,
        coins: Double,
        incomePerSecond: Double,
        safety: Int,
        slots: [VaultSlot]
    ) -> RaidPlan {
        let waveCount = min(2 + level / 3, 4)
        let total = min(6 + level, 22)
        let gap = max(0.55, 1.2 - 0.04 * Double(level))
        let pool = ThiefKind.allCases.filter { $0.spawnWeight > 0 && $0.firstRaid <= level }
        let newcomer = ThiefKind.allCases.first { $0.firstRaid == level && $0 != .slimeling }
        let hasBoss = isBossRaid(level: level)

        var spawns: [ThiefSpawn] = []
        var time = 0.6
        var previousLane = 0.5

        for wave in 1...waveCount {
            // Whatever does not divide evenly goes to the last waves, so raids build up.
            let extra = wave > waveCount - total % waveCount ? 1 : 0
            var kinds = (0..<(total / waveCount + extra)).map { _ in randomKind(from: pool) }

            // Make sure a monster's first raid actually features it.
            if wave == 1, let newcomer, newcomer.spawnWeight > 0 {
                kinds[0] = newcomer
                if kinds.count > 2 {
                    kinds[2] = newcomer
                }
            }
            if hasBoss, wave == waveCount {
                kinds.insert(.boneKing, at: 0)
            }

            for kind in kinds {
                var lane = kind.isBoss ? 0.5 : Double.random(in: 0.14...0.86)
                // Keep neighbours apart so they do not stack on one spot.
                if !kind.isBoss, abs(lane - previousLane) < 0.18 {
                    lane = previousLane < 0.5 ? lane + 0.3 : lane - 0.3
                    lane = min(0.86, max(0.14, lane))
                }
                previousLane = lane

                spawns.append(
                    ThiefSpawn(
                        id: spawns.count,
                        kind: kind,
                        time: time,
                        lane: lane,
                        hp: hitPoints(for: kind, level: level),
                        wave: wave
                    )
                )
                time += kind.isBoss ? gap * 2 : gap
            }
            time += wavePause - gap
        }

        let kept = 1 - mitigation(safety: safety)
        return RaidPlan(
            level: level,
            spawns: spawns,
            waveCount: waveCount,
            speedScale: min(1.4, 1 + 0.03 * Double(level - 1)),
            tapDamage: tapDamage(safety: safety),
            lootPerWeight: (coins * 0.02 * kept).rounded(.down),
            // With a decent combo a clean defense pays about 40 seconds of income:
            // worth fighting for, never a replacement for building.
            bountyPerWeight: max(5, (incomePerSecond * 2).rounded()),
            powers: powers(for: slots),
            newcomer: newcomer
        )
    }

    private static func randomKind(from pool: [ThiefKind]) -> ThiefKind {
        var roll = Double.random(in: 0..<pool.reduce(0) { $0 + $1.spawnWeight })
        for kind in pool {
            roll -= kind.spawnWeight
            if roll < 0 {
                return kind
            }
        }
        return .skeleton
    }
}
