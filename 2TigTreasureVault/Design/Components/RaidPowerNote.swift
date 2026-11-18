//
//  RaidPowerNote.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

extension RaidPower {
    /// One color per power, used wherever the power shows up.
    var tint: Color {
        switch self {
        case .flameBurst: VaultPalette.ember
        case .stoneWard: VaultPalette.safety
        case .tigerRoar: VaultPalette.gold
        }
    }
}

/// One line telling the keeper which raid power a treasure grants.
struct RaidPowerNote: View {
    let power: RaidPower

    var body: some View {
        Label("Raid power: \(power.name)", systemImage: power.symbol)
            .font(VaultFont.body(.caption, weight: .semibold))
            .foregroundStyle(power.tint)
            .accessibilityHint(power.effect)
    }
}
