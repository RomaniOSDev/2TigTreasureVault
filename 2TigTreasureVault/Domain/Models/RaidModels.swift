//
//  RaidModels.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import Foundation

/// Everything that can come through the gate.
enum ThiefKind: String, CaseIterable, Identifiable {
    case skeleton
    case bat
    case runner
    case slime
    case slimeling
    case brute
    case ghost
    case boneKing

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .skeleton: "Bone Thief"
        case .bat: "Cave Bat"
        case .runner: "Swift Thief"
        case .slime: "Gold Slime"
        case .slimeling: "Slimeling"
        case .brute: "Brute Thief"
        case .ghost: "Vault Ghost"
        case .boneKing: "Bone King"
        }
    }

    /// One line on how to deal with it.
    var tip: String {
        switch self {
        case .skeleton: "Plain and steady. A couple of taps will do."
        case .bat: "Swerves through the air. Catch it mid-swoop."
        case .runner: "Fast but fragile. Do not let it slip by."
        case .slime: "Bursts into two slimelings when it pops."
        case .slimeling: "Small, quick and easy to miss."
        case .brute: "Slow, tough and very greedy."
        case .ghost: "Fades out of reach. Strike while it is solid."
        case .boneKing: "Calls skeletons to his side. Bring him down fast."
        }
    }

    /// First raid this monster shows up in. The Bone King leads every fifth raid.
    var firstRaid: Int {
        switch self {
        case .skeleton: 1
        case .bat: 2
        case .runner: 3
        case .slime, .slimeling: 4
        case .brute: 6
        case .ghost: 7
        case .boneKing: RaidPlanner.bossEvery
        }
    }

    var baseHP: Int {
        switch self {
        case .skeleton: 2
        case .bat: 1
        case .runner: 1
        case .slime: 3
        case .slimeling: 1
        case .brute: 5
        case .ghost: 2
        case .boneKing: 24
        }
    }

    /// Seconds to get from the gate to the hoard at normal speed.
    var crossingTime: Double {
        switch self {
        case .skeleton: 9
        case .bat: 6.5
        case .runner: 5.5
        case .slime: 11
        case .slimeling: 7.5
        case .brute: 12.5
        case .ghost: 10
        case .boneKing: 32
        }
    }

    /// How much it carries off, relative to a plain skeleton.
    var lootWeight: Double {
        switch self {
        case .skeleton: 1
        case .bat: 0.5
        case .runner: 0.7
        case .slime: 1.2
        case .slimeling: 0.4
        case .brute: 2.2
        case .ghost: 1.4
        case .boneKing: 6
        }
    }

    var bountyWeight: Double {
        switch self {
        case .skeleton: 1
        case .bat: 0.7
        case .runner: 0.8
        case .slime: 1
        case .slimeling: 0.4
        case .brute: 2.5
        case .ghost: 1.6
        case .boneKing: 8
        }
    }

    /// How often it shows up in a random wave. Zero means it never spawns on its own.
    var spawnWeight: Double {
        switch self {
        case .skeleton: 5
        case .bat: 3
        case .runner: 3
        case .slime: 2
        case .brute: 2
        case .ghost: 2
        case .slimeling, .boneKing: 0
        }
    }

    /// Side-to-side drift as a share of the cave's width.
    var swayWidth: Double {
        switch self {
        case .bat: 0.17
        case .ghost: 0.05
        case .slime, .slimeling, .boneKing: 0
        case .skeleton, .runner, .brute: 0.02
        }
    }

    var swaySpeed: Double {
        switch self {
        case .bat: 3.4
        case .ghost: 1.6
        default: 3
        }
    }

    /// How high above the floor it travels, relative to its own height.
    var lift: Double {
        switch self {
        case .bat: 0.55
        case .ghost: 0.12
        default: 0
        }
    }

    var isBoss: Bool { self == .boneKing }
}

struct ThiefSpawn: Identifiable {
    let id: Int
    let kind: ThiefKind
    /// Seconds after the fight starts.
    let time: Double
    /// Horizontal position, 0...1 across the cave.
    let lane: Double
    let hp: Int
    /// 1-based wave this spawn belongs to.
    let wave: Int
}

/// Everything the raid screen needs, fixed at the moment the raid begins.
struct RaidPlan: Identifiable {
    let id = UUID()
    let level: Int
    let spawns: [ThiefSpawn]
    let waveCount: Int
    let speedScale: Double
    let tapDamage: Int
    let lootPerWeight: Double
    let bountyPerWeight: Double
    /// Powers the vault's treasures grant for this fight.
    let powers: Set<RaidPower>
    /// A monster the keeper meets for the first time in this raid.
    let newcomer: ThiefKind?

    var hasBoss: Bool {
        spawns.contains { $0.kind.isBoss }
    }
}

struct RaidOutcome {
    let level: Int
    let repelled: Int
    let escaped: Int
    let bounty: Double
    let stolen: Double
    var bestCombo = 0
    var bossesDefeated = 0

    var isFlawless: Bool { escaped == 0 }
}
