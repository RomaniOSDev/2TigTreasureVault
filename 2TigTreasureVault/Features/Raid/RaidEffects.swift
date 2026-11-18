//
//  RaidEffects.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

/// Ring and glint where a tap landed.
struct SparkView: View {
    /// 0 when it appears, 1 when it is gone.
    let life: Double

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(VaultPalette.goldLight, lineWidth: 3)
                .frame(width: 26 + life * 56, height: 26 + life * 56)
            Image(systemName: "sparkle")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
                .scaleEffect(1 - life * 0.5)
        }
        .opacity(1 - life)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

/// Wash of color and a shockwave rolling out from the hoard when a power goes off.
struct PowerFlash: View {
    let blast: RaidViewModel.Blast?

    var body: some View {
        ZStack(alignment: .bottom) {
            if let blast {
                let life = blast.age / RaidViewModel.blastDuration

                RadialGradient(
                    colors: [blast.power.tint.opacity(0.6), blast.power.tint.opacity(0.18), .clear],
                    center: .bottom,
                    startRadius: 0,
                    endRadius: 720
                )
                .opacity(1 - life)

                Circle()
                    .stroke(blast.power.tint.opacity(0.9), lineWidth: 4)
                    .frame(width: 220, height: 220)
                    .scaleEffect(0.4 + life * 7)
                    .opacity(1 - life)
                    .offset(y: 20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .clipped()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

/// Red pulse around the screen edges when a monster reaches the gold.
struct BreachFlash: View {
    let trigger: Int
    @State private var strength = 0.0

    var body: some View {
        RadialGradient(
            colors: [.clear, VaultPalette.danger.opacity(0.6)],
            center: .center,
            startRadius: 140,
            endRadius: 520
        )
        .opacity(strength)
        .allowsHitTesting(false)
        .onChange(of: trigger) {
            strength = 1
            withAnimation(.easeOut(duration: 0.55)) {
                strength = 0
            }
        }
    }
}

/// Big callout in the middle of the cave: a new wave, the boss, a power.
struct RaidBannerView: View {
    let banner: RaidViewModel.Banner

    var body: some View {
        let life = banner.age / RaidViewModel.bannerDuration
        // Snap in, hold, fade out.
        let visibility = min(1, life * 9) * min(1, (1 - life) * 3.5)

        Text(banner.title)
            .font(.system(size: 34, weight: .bold, design: .serif))
            .foregroundStyle(banner.isAlarm ? VaultPalette.danger : VaultPalette.textPrimary)
            .shadow(color: .black.opacity(0.85), radius: 6, y: 2)
            .lineLimit(1)
            .fixedSize()
            .scaleEffect(0.86 + 0.14 * min(1, life * 9))
            .opacity(visibility)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

/// Kills in a row and the bounty bonus they are worth.
struct ComboBadge: View {
    let combo: Int

    private var bonusPercent: Int {
        Int(((RaidPlanner.comboMultiplier(combo + 1) - 1) * 100).rounded())
    }

    var body: some View {
        HStack(spacing: 8) {
            Text("Combo ×\(combo)")
                .font(VaultFont.number(.subheadline))
                .foregroundStyle(VaultPalette.gold)
                .contentTransition(.numericText())
            Text("+\(bonusPercent)% bounty")
                .font(VaultFont.body(.caption, weight: .semibold))
                .foregroundStyle(VaultPalette.textSecondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .background(VaultPalette.panel.opacity(0.9), in: Capsule())
        .overlay {
            Capsule().strokeBorder(VaultPalette.gold.opacity(0.5), lineWidth: 1)
        }
        .animation(.snappy(duration: 0.2), value: combo)
        .allowsHitTesting(false)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Combo \(combo), plus \(bonusPercent) percent bounty")
    }
}