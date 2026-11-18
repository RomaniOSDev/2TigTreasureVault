//
//  RaidOverlays.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

/// Top bar during a raid. Sits in an overlay so it never covers the playfield's touches.
struct RaidHUDView: View {
    let level: Int
    /// 0 until the first wave is announced.
    let wave: Int
    let waveCount: Int
    let remaining: Int
    let bounty: Double
    let stolen: Double
    let onRetreat: () -> Void

    private var status: String {
        let left = remaining == 1 ? "1 left" : "\(remaining) left"
        guard wave > 0 else { return "\(waveCount) waves · \(left)" }
        return "Wave \(wave) of \(waveCount) · \(left)"
    }

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onRetreat) {
                Image(systemName: "flag.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(VaultPalette.textSecondary)
                    .frame(width: 44, height: 44)
                    .background(VaultPalette.panelRaised, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Retreat")

            VStack(alignment: .leading, spacing: 2) {
                Text("Raid \(level)")
                    .font(VaultFont.title(.headline))
                    .foregroundStyle(VaultPalette.textPrimary)
                Text(status)
                    .font(VaultFont.body(.footnote, weight: .medium))
                    .foregroundStyle(VaultPalette.spectral)
                    .lineLimit(1)
            }
            .layoutPriority(1)

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 2) {
                CoinLabel(amount: bounty, prefix: "+")
                    .foregroundStyle(VaultPalette.gold)
                if stolen >= 1 {
                    CoinLabel(amount: stolen, prefix: "-")
                        .foregroundStyle(VaultPalette.danger)
                }
            }
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: VaultMetrics.panelRadius, style: .continuous)
                .fill(VaultPalette.panel.opacity(0.9))
        }
        .overlay {
            RoundedRectangle(cornerRadius: VaultMetrics.panelRadius, style: .continuous)
                .strokeBorder(VaultPalette.spectral.opacity(0.35), lineWidth: 1)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

/// "Get ready" card shown for the first seconds of a raid. Introduces a monster the first time it comes.
struct RaidCountdownView: View {
    let seconds: Double
    let plan: RaidPlan

    private var title: String {
        plan.hasBoss ? "The Bone King is coming" : "Thieves incoming"
    }

    /// The boss outranks any other newcomer.
    private var featured: ThiefKind? {
        plan.hasBoss ? .boneKing : plan.newcomer
    }

    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(VaultFont.title(.title2))
                .foregroundStyle(plan.hasBoss ? VaultPalette.danger : VaultPalette.textPrimary)
                .multilineTextAlignment(.center)

            Text("\(max(1, Int(seconds.rounded(.up))))")
                .font(.system(size: 64, weight: .heavy, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(VaultPalette.spectral)
                .contentTransition(.numericText(countsDown: true))

            if let featured {
                HStack(spacing: 12) {
                    ThiefArt(kind: featured)
                        .frame(width: 60, height: 60)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(featured.isBoss ? featured.displayName : "New: \(featured.displayName)")
                            .font(VaultFont.body(.subheadline, weight: .bold))
                            .foregroundStyle(VaultPalette.textPrimary)
                        Text(featured.tip)
                            .font(VaultFont.body(.footnote))
                            .foregroundStyle(VaultPalette.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 0)
                }
                .padding(10)
                .background(VaultPalette.panelRaised, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            } else {
                Text("Tap them before they reach the gold.")
                    .font(VaultFont.body(.subheadline))
                    .foregroundStyle(VaultPalette.textSecondary)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 8) {
                StatChip(
                    symbol: "hand.tap.fill",
                    text: "Tap power \(plan.tapDamage)",
                    tint: VaultPalette.safety,
                    accessibilityName: ""
                )
                StatChip(
                    symbol: "water.waves",
                    text: "\(plan.waveCount) waves",
                    tint: VaultPalette.spectral,
                    accessibilityName: ""
                )
            }
        }
        .vaultPanel(padding: 20, stroke: (plan.hasBoss ? VaultPalette.danger : VaultPalette.spectral).opacity(0.5))
        .padding(.horizontal, 32)
        .allowsHitTesting(false)
        .accessibilityElement(children: .combine)
    }
}

/// Summary after the last monster is gone.
struct RaidResultView: View {
    let outcome: RaidOutcome
    let onContinue: () -> Void

    private var title: String {
        if outcome.bossesDefeated > 0, outcome.isFlawless { return "The king has fallen" }
        if outcome.isFlawless { return "Vault defended" }
        if outcome.repelled == 0 { return "The gate fell" }
        return "Raid over"
    }

    private var message: String {
        if outcome.isFlawless { return "Not a single coin left the cave." }
        if outcome.repelled == 0 { return "The thieves took what they came for." }
        return "Some thieves slipped past with loot."
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Image(systemName: outcome.isFlawless ? "shield.lefthalf.filled" : "shield.slash.fill")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(outcome.isFlawless ? VaultPalette.gold : VaultPalette.spectral)
                    .accessibilityHidden(true)

                VStack(spacing: 6) {
                    Text(title)
                        .font(VaultFont.title(.title))
                        .foregroundStyle(VaultPalette.textPrimary)
                    Text(message)
                        .font(VaultFont.body(.subheadline))
                        .foregroundStyle(VaultPalette.textSecondary)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 12) {
                    ResultRow(title: "Monsters repelled") {
                        Text("\(outcome.repelled) of \(outcome.repelled + outcome.escaped)")
                            .font(VaultFont.number(.subheadline))
                            .foregroundStyle(VaultPalette.textPrimary)
                    }
                    if outcome.bestCombo >= 2 {
                        ResultRow(title: "Best combo") {
                            Text("×\(outcome.bestCombo)")
                                .font(VaultFont.number(.subheadline))
                                .foregroundStyle(VaultPalette.gold)
                        }
                    }
                    ResultRow(title: "Bounty earned") {
                        CoinLabel(amount: outcome.bounty, prefix: "+")
                            .foregroundStyle(VaultPalette.gold)
                    }
                    ResultRow(title: "Coins stolen") {
                        CoinLabel(amount: outcome.stolen, prefix: outcome.stolen >= 1 ? "-" : "")
                            .foregroundStyle(outcome.stolen >= 1 ? VaultPalette.danger : VaultPalette.textSecondary)
                    }
                }
                .padding(14)
                .background(VaultPalette.panelRaised, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                Button("Back to the vault", action: onContinue)
                    .buttonStyle(GoldButtonStyle())
            }
            .vaultPanel(padding: 22)
            .padding(.horizontal, 28)
            .frame(maxWidth: 420)
        }
        .accessibilityAddTraits(.isModal)
    }
}

private struct ResultRow<Value: View>: View {
    let title: String
    @ViewBuilder var value: Value

    var body: some View {
        HStack {
            Text(title)
                .font(VaultFont.body(.subheadline, weight: .medium))
                .foregroundStyle(VaultPalette.textSecondary)
            Spacer(minLength: 8)
            value
        }
    }
}

#Preview {
    ZStack {
        CaveBackdrop(mood: .raid).ignoresSafeArea()
        RaidResultView(
            outcome: RaidOutcome(level: 3, repelled: 7, escaped: 1, bounty: 480, stolen: 120, bestCombo: 5)
        ) {}
    }
}
