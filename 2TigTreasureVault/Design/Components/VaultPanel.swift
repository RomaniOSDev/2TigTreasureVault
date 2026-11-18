//
//  VaultPanel.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

private struct VaultPanelModifier: ViewModifier {
    let padding: CGFloat
    let stroke: Color

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: VaultMetrics.panelRadius, style: .continuous)
                    .fill(VaultPalette.panel)
            }
            .overlay {
                RoundedRectangle(cornerRadius: VaultMetrics.panelRadius, style: .continuous)
                    .strokeBorder(stroke, lineWidth: 1)
            }
    }
}

extension View {
    /// Standard dark card with a faint gold edge.
    func vaultPanel(padding: CGFloat = 16, stroke: Color = VaultPalette.panelStroke) -> some View {
        modifier(VaultPanelModifier(padding: padding, stroke: stroke))
    }
}

/// Thin progress track used for ranks, goals and countdowns.
struct VaultProgressBar: View {
    let value: Double
    var tint: Color = VaultPalette.gold
    var height: CGFloat = 8

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.black.opacity(0.35))
                Capsule()
                    .fill(tint)
                    .frame(width: max(height, geo.size.width * min(1, max(0, value))))
                    .opacity(value > 0 ? 1 : 0)
            }
        }
        .frame(height: height)
        .accessibilityHidden(true)
    }
}
