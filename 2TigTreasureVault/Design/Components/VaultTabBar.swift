//
//  VaultTabBar.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

enum VaultTab: String, CaseIterable, Identifiable {
    case vault
    case goals
    case ledger
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .vault: "Vault"
        case .goals: "Goals"
        case .ledger: "Ledger"
        case .settings: "Settings"
        }
    }

    var symbol: String {
        switch self {
        case .vault: "shippingbox.fill"
        case .goals: "flag.fill"
        case .ledger: "book.closed.fill"
        case .settings: "gearshape.fill"
        }
    }
}

/// Floating tab bar. Content scrolls underneath it.
struct VaultTabBar: View {
    @Binding var selection: VaultTab
    var badgedTab: VaultTab?

    var body: some View {
        HStack(spacing: 0) {
            ForEach(VaultTab.allCases) { tab in
                Button {
                    selection = tab
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.symbol)
                            .font(.system(size: 19, weight: .semibold))
                            .overlay(alignment: .topTrailing) {
                                if badgedTab == tab {
                                    Circle()
                                        .fill(VaultPalette.ember)
                                        .frame(width: 9, height: 9)
                                        .offset(x: 6, y: -3)
                                }
                            }
                        Text(tab.title)
                            .font(VaultFont.body(.caption2, weight: .semibold))
                    }
                    .foregroundStyle(selection == tab ? VaultPalette.gold : VaultPalette.textMuted)
                    .frame(maxWidth: .infinity, minHeight: VaultMetrics.tabBarHeight)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title)
                .accessibilityValue(badgedTab == tab ? "Rewards ready" : "")
                .accessibilityAddTraits(selection == tab ? .isSelected : [])
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(VaultPalette.panel)
                .shadow(color: .black.opacity(0.45), radius: 14, y: 6)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(VaultPalette.panelStroke, lineWidth: 1)
        }
    }
}

#Preview {
    VaultTabBar(selection: .constant(.vault), badgedTab: .goals)
        .padding()
        .background(VaultBackgroundView())
}
