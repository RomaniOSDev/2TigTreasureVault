//
//  RaidPower.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import Foundation

/// A special move in a raid. Each one is granted by a treasure standing in the vault.
enum RaidPower: String, CaseIterable, Identifiable {
    case flameBurst
    case stoneWard
    case tigerRoar

    var id: String { rawValue }

    var name: String {
        switch self {
        case .flameBurst: "Flame Burst"
        case .stoneWard: "Stone Ward"
        case .tigerRoar: "Tiger Roar"
        }
    }

    var effect: String {
        switch self {
        case .flameBurst: "Scorches every monster in the cave."
        case .stoneWard: "Turns every monster to stone for a few seconds."
        case .tigerRoar: "Hurls every monster back toward the gate."
        }
    }

    /// Short reminder shown under a locked power.
    var requirement: String {
        switch self {
        case .flameBurst: "Needs a torch"
        case .stoneWard: "Needs a guardian"
        case .tigerRoar: "Needs a tiger"
        }
    }

    var symbol: String {
        switch self {
        case .flameBurst: "flame.fill"
        case .stoneWard: "shield.lefthalf.filled"
        case .tigerRoar: "pawprint.fill"
        }
    }

    /// Treasures that grant this power. Any one of them is enough.
    var sources: [VaultItemKind] {
        switch self {
        case .flameBurst: [.torch, .brazier]
        case .stoneWard: [.guardianStatue]
        case .tigerRoar: [.tigerStatue]
        }
    }

    /// Seconds before it can be used again.
    var cooldown: Double {
        switch self {
        case .flameBurst: 12
        case .stoneWard: 16
        case .tigerRoar: 20
        }
    }

    static func granted(by kind: VaultItemKind) -> RaidPower? {
        allCases.first { $0.sources.contains(kind) }
    }
}
