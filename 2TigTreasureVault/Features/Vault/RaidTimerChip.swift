//
//  RaidTimerChip.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

/// Tells the keeper when the next raid is due and lets them start it early.
/// Always on screen, so the cave below never shifts when its state changes.
struct RaidTimerChip: View {
    enum Phase {
        /// The vault is still too poor for thieves to care.
        case quiet
        case counting(seconds: Double)
        case atTheGate
    }

    let phase: Phase
    let level: Int
    let isBoss: Bool
    let onFight: () -> Void

    private var title: String {
        let name = isBoss ? "Bone King" : "Raid \(level)"
        switch phase {
        case .quiet: return "All quiet for now"
        case .counting(let seconds): return "\(name) in \(Self.clock(seconds))"
        case .atTheGate: return "\(name) is at the gate"
        }
    }

    private var tint: Color {
        isBoss ? VaultPalette.danger : VaultPalette.spectral
    }

    var body: some View {
        HStack(spacing: 10) {
            ThiefArt(kind: isBoss ? .boneKing : .skeleton)
                .frame(width: 30, height: 30)
                .saturation(isQuiet ? 0 : 1)
                .opacity(isQuiet ? 0.5 : 1)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(VaultFont.body(.subheadline, weight: .semibold))
                    .foregroundStyle(isQuiet ? VaultPalette.textMuted : VaultPalette.textPrimary)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                if isQuiet {
                    Text("Thieves notice a vault with a few treasures.")
                        .font(VaultFont.body(.caption2))
                        .foregroundStyle(VaultPalette.textMuted)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }

            Spacer(minLength: 0)

            if case .counting = phase {
                Button(action: onFight) {
                    Text("Fight now")
                        .font(VaultFont.body(.footnote, weight: .bold))
                        .foregroundStyle(tint)
                        .padding(.horizontal, 12)
                        .frame(minHeight: 32)
                        .background(tint.opacity(0.14), in: Capsule())
                        .overlay {
                            Capsule().strokeBorder(tint.opacity(0.55), lineWidth: 1)
                        }
                        // The visible pill is small; the touch target is the full height of the chip.
                        .padding(.vertical, 6)
                        .padding(.leading, 8)
                        .contentShape(Rectangle())
                }
                .buttonStyle(SqueezeButtonStyle())
                .accessibilityHint("Starts the next raid right away")
            }
        }
        .padding(.leading, 10)
        .padding(.trailing, 8)
        .frame(height: 44)
        .background {
            RoundedRectangle(cornerRadius: VaultMetrics.controlRadius, style: .continuous)
                .fill(VaultPalette.panel.opacity(0.9))
        }
        .overlay {
            RoundedRectangle(cornerRadius: VaultMetrics.controlRadius, style: .continuous)
                .strokeBorder(isQuiet ? VaultPalette.panelStroke : tint.opacity(0.4), lineWidth: 1)
        }
    }

    private var isQuiet: Bool {
        if case .quiet = phase { return true }
        return false
    }

    /// 75 -> "1:15".
    private static func clock(_ seconds: Double) -> String {
        let total = Int(max(0, seconds).rounded(.up))
        let rest = total % 60
        return "\(total / 60):\(rest < 10 ? "0" : "")\(rest)"
    }
}

#Preview {
    VStack(spacing: 12) {
        RaidTimerChip(phase: .quiet, level: 1, isBoss: false) {}
        RaidTimerChip(phase: .counting(seconds: 42), level: 3, isBoss: false) {}
        RaidTimerChip(phase: .counting(seconds: 75), level: 5, isBoss: true) {}
        RaidTimerChip(phase: .atTheGate, level: 4, isBoss: false) {}
    }
    .padding()
    .background(VaultPalette.caveShadow)
}
