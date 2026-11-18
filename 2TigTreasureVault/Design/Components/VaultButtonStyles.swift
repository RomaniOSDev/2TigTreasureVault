//
//  VaultButtonStyles.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

/// Primary action: solid gold.
struct GoldButtonStyle: ButtonStyle {
    var isCompact = false

    func makeBody(configuration: Configuration) -> some View {
        GoldButtonBody(configuration: configuration, isCompact: isCompact)
    }

    private struct GoldButtonBody: View {
        let configuration: ButtonStyleConfiguration
        let isCompact: Bool
        @Environment(\.isEnabled) private var isEnabled

        var body: some View {
            configuration.label
                .font(VaultFont.body(isCompact ? .subheadline : .headline, weight: .bold))
                .foregroundStyle(isEnabled ? VaultPalette.textOnGold : VaultPalette.textMuted)
                .padding(.horizontal, isCompact ? 14 : 20)
                .frame(maxWidth: isCompact ? nil : .infinity, minHeight: isCompact ? 44 : 52)
                .background {
                    RoundedRectangle(cornerRadius: VaultMetrics.controlRadius, style: .continuous)
                        .fill(
                            isEnabled
                                ? AnyShapeStyle(VaultPalette.goldGradient)
                                : AnyShapeStyle(VaultPalette.panelRaised)
                        )
                }
                .overlay {
                    RoundedRectangle(cornerRadius: VaultMetrics.controlRadius, style: .continuous)
                        .strokeBorder(
                            isEnabled ? VaultPalette.goldLight.opacity(0.7) : VaultPalette.textMuted.opacity(0.3),
                            lineWidth: 1
                        )
                }
                .scaleEffect(configuration.isPressed ? 0.97 : 1)
                .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
        }
    }
}

/// Secondary action: outlined, takes the tint it is given.
struct OutlineButtonStyle: ButtonStyle {
    var tint: Color = VaultPalette.gold
    var isCompact = false

    func makeBody(configuration: Configuration) -> some View {
        OutlineButtonBody(configuration: configuration, tint: tint, isCompact: isCompact)
    }

    private struct OutlineButtonBody: View {
        let configuration: ButtonStyleConfiguration
        let tint: Color
        let isCompact: Bool
        @Environment(\.isEnabled) private var isEnabled

        var body: some View {
            configuration.label
                .font(VaultFont.body(isCompact ? .subheadline : .headline, weight: .semibold))
                .foregroundStyle(isEnabled ? tint : VaultPalette.textMuted)
                .padding(.horizontal, isCompact ? 14 : 20)
                .frame(maxWidth: isCompact ? nil : .infinity, minHeight: isCompact ? 44 : 52)
                .background {
                    RoundedRectangle(cornerRadius: VaultMetrics.controlRadius, style: .continuous)
                        .fill(tint.opacity(configuration.isPressed ? 0.18 : 0.08))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: VaultMetrics.controlRadius, style: .continuous)
                        .strokeBorder((isEnabled ? tint : VaultPalette.textMuted).opacity(0.55), lineWidth: 1)
                }
                .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
        }
    }
}

/// For tappable things in the cave: just a quick squeeze.
struct SqueezeButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.93 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
