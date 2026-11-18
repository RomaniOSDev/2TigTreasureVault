//
//  ShellOverlays.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

/// One-line message that floats above the tab bar for a few seconds.
struct NoticeToast: View {
    let notice: VaultNotice

    private var tint: Color {
        notice.tone == .good ? VaultPalette.gold : VaultPalette.danger
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: notice.tone == .good ? "crown.fill" : "exclamationmark.triangle.fill")
                .foregroundStyle(tint)
            Text(notice.text)
                .font(VaultFont.body(.subheadline, weight: .semibold))
                .foregroundStyle(VaultPalette.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .vaultPanel(padding: 14, stroke: tint.opacity(0.5))
        .accessibilityElement(children: .combine)
    }
}

/// Shown on every tab while thieves wait at the gate.
struct RaidAlertBanner: View {
    let isBoss: Bool
    let toll: Double
    let onDefend: () -> Void
    let onPay: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ThiefArt(kind: isBoss ? .boneKing : .skeleton)
                    .frame(width: 52, height: 52)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 2) {
                    Text(isBoss ? "The Bone King is at the gate" : "Thieves at the gate")
                        .font(VaultFont.title(.headline))
                        .foregroundStyle(VaultPalette.textPrimary)
                    Text("Income is on hold until they are gone.")
                        .font(VaultFont.body(.footnote))
                        .foregroundStyle(VaultPalette.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            HStack(spacing: 10) {
                Button(action: onPay) {
                    if toll >= 1 {
                        HStack(spacing: 6) {
                            Text("Pay")
                            CoinLabel(amount: toll)
                        }
                    } else {
                        Text("Let them in")
                    }
                }
                .buttonStyle(OutlineButtonStyle(tint: VaultPalette.spectral))

                Button("Defend", action: onDefend)
                    .buttonStyle(GoldButtonStyle())
            }
        }
        .vaultPanel(padding: 14, stroke: VaultPalette.spectral.opacity(0.6))
    }
}

/// Welcome-back summary of coins earned while the app was closed.
struct AwayEarningsCard: View {
    let report: AwayReport
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.65)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                CoinPileArt()
                    .frame(width: 120, height: 120)
                    .accessibilityHidden(true)

                VStack(spacing: 6) {
                    Text("Welcome back, Keeper")
                        .font(VaultFont.title(.title2))
                        .foregroundStyle(VaultPalette.textPrimary)
                        .multilineTextAlignment(.center)
                    Text("Your treasures kept working for \(CoinFormatter.duration(report.seconds)).")
                        .font(VaultFont.body(.subheadline))
                        .foregroundStyle(VaultPalette.textSecondary)
                        .multilineTextAlignment(.center)
                }

                CoinLabel(amount: report.coins, style: .largeTitle, iconSize: 30, prefix: "+")
                    .foregroundStyle(VaultPalette.gold)

                Text("While you are away the vault earns at half pace, for up to 6 hours.")
                    .font(VaultFont.body(.footnote))
                    .foregroundStyle(VaultPalette.textMuted)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Button("Continue", action: onDismiss)
                    .buttonStyle(GoldButtonStyle())
            }
            .vaultPanel(padding: 22)
            .padding(.horizontal, 28)
            .frame(maxWidth: 420)
        }
        .accessibilityAddTraits(.isModal)
    }
}

#Preview {
    ZStack {
        VaultBackgroundView()
        VStack(spacing: 12) {
            NoticeToast(notice: VaultNotice(text: "Your vault is now a Gilded Den.", tone: .good))
            RaidAlertBanner(isBoss: false, toll: 1_250, onDefend: {}, onPay: {})
        }
        .padding()
    }
}
