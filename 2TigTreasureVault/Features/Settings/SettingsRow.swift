//
//  SettingsRow.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

/// One tappable line in the settings list: icon, title and a trailing hint.
struct SettingsRow: View {
    enum Accessory {
        /// Opens another screen inside the app.
        case push
        /// Leaves the app for the browser.
        case external
        case none

        var symbol: String? {
            switch self {
            case .push: "chevron.right"
            case .external: "arrow.up.right"
            case .none: nil
            }
        }
    }

    let title: String
    let symbol: String
    var accessory: Accessory = .push
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: symbol)
                    .font(.title3)
                    .foregroundStyle(VaultPalette.gold)
                    .frame(width: 28)
                Text(title)
                    .font(VaultFont.body(.body, weight: .semibold))
                    .foregroundStyle(VaultPalette.textPrimary)
                Spacer()
                if let trailing = accessory.symbol {
                    Image(systemName: trailing)
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(VaultPalette.textMuted)
                }
            }
            .frame(minHeight: 28)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .vaultPanel()
    }
}

#Preview {
    VStack(spacing: 12) {
        SettingsRow(title: "How to play", symbol: "questionmark.circle.fill") {}
        SettingsRow(title: "Privacy Policy", symbol: "hand.raised.fill", accessory: .external) {}
        SettingsRow(title: "Rate Us", symbol: "star.fill", accessory: .none) {}
    }
    .padding()
    .background(VaultPalette.caveShadow)
}
