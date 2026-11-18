//
//  RaidPowerBar.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

/// The keeper's special moves. Locked ones stay visible and say which treasure grants them.
struct RaidPowerBar: View {
    /// Fixed so the raid screen can lay the hoard and the playfield out around it.
    static let height: CGFloat = 86

    let unlocked: Set<RaidPower>
    /// 0 when ready, 1 right after use.
    let cooldownFraction: (RaidPower) -> Double
    /// Powers only fire while the fight is on.
    let isActive: Bool
    let onUse: (RaidPower) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(RaidPower.allCases) { power in
                PowerButton(
                    power: power,
                    isUnlocked: unlocked.contains(power),
                    cooldownFraction: cooldownFraction(power),
                    isActive: isActive
                ) {
                    onUse(power)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: Self.height, alignment: .top)
    }
}

private struct PowerButton: View {
    let power: RaidPower
    let isUnlocked: Bool
    let cooldownFraction: Double
    let isActive: Bool
    let onUse: () -> Void

    private var isCharged: Bool { isUnlocked && cooldownFraction <= 0 }
    private var isReady: Bool { isCharged && isActive }

    private var stateText: String {
        if !isUnlocked { return power.requirement }
        return isCharged ? "Ready" : "Recharging"
    }

    var body: some View {
        Button(action: onUse) {
            VStack(spacing: 5) {
                ZStack {
                    Circle()
                        .fill(isCharged ? AnyShapeStyle(power.tint.opacity(0.28)) : AnyShapeStyle(VaultPalette.panel.opacity(0.92)))
                    Circle()
                        .strokeBorder(VaultPalette.textMuted.opacity(0.3), lineWidth: 3)
                    if isUnlocked {
                        // The ring fills up as the power recharges.
                        Circle()
                            .inset(by: 1.5)
                            .trim(from: 0, to: 1 - cooldownFraction)
                            .stroke(power.tint, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                    }
                    Image(systemName: isUnlocked ? power.symbol : "lock.fill")
                        .font(.system(size: isUnlocked ? 22 : 17, weight: .bold))
                        .foregroundStyle(isCharged ? power.tint : VaultPalette.textMuted)
                }
                .frame(width: 54, height: 54)
                .shadow(color: isCharged ? power.tint.opacity(0.55) : .clear, radius: 8)

                Text(isUnlocked ? power.name : power.requirement)
                    .font(VaultFont.body(.caption2, weight: .semibold))
                    .foregroundStyle(isCharged ? VaultPalette.textPrimary : VaultPalette.textMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(SqueezeButtonStyle())
        .disabled(!isReady)
        .accessibilityLabel(power.name)
        .accessibilityValue(stateText)
        .accessibilityHint(power.effect)
    }
}

#Preview {
    ZStack(alignment: .bottom) {
        CaveBackdrop(mood: .raid).ignoresSafeArea()
        RaidPowerBar(
            unlocked: [.flameBurst, .stoneWard],
            cooldownFraction: { $0 == .stoneWard ? 0.6 : 0 },
            isActive: true,
            onUse: { _ in }
        )
    }
}
