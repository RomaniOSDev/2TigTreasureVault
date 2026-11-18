//
//  VaultSlotView.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

/// One pedestal in the cave: buried, empty, or holding an item.
struct VaultSlotView: View {
    enum Content {
        /// `cost` is set only for the pedestal that can be dug out next.
        case locked(cost: Double?)
        case empty
        case item(PlacedItem, canUpgrade: Bool)
    }

    let content: Content
    let number: Int
    let unit: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottom) {
                switch content {
                case .locked(let cost):
                    lockedBody(cost: cost)
                case .empty:
                    emptyBody
                case .item(let item, let canUpgrade):
                    itemBody(item, canUpgrade: canUpgrade)
                }
            }
            .frame(width: unit, height: unit * 1.08, alignment: .bottom)
            .contentShape(Rectangle())
        }
        .buttonStyle(SqueezeButtonStyle())
        .accessibilityLabel(accessibilityText)
        .accessibilityHint(accessibilityHintText)
    }

    // MARK: States

    private func lockedBody(cost: Double?) -> some View {
        ZStack(alignment: .bottom) {
            PedestalArt(look: .rubble)
                .frame(width: unit, height: unit * 0.4)

            VStack(spacing: unit * 0.05) {
                Image(systemName: "lock.fill")
                    .font(.system(size: unit * 0.22, weight: .bold))
                    .foregroundStyle(cost == nil ? VaultPalette.textMuted : VaultPalette.goldLight)

                if let cost {
                    HStack(spacing: 3) {
                        CoinIcon(size: unit * 0.15)
                        Text(CoinFormatter.short(cost))
                            .font(VaultFont.scene(unit * 0.14))
                            .foregroundStyle(VaultPalette.textPrimary)
                    }
                    .padding(.horizontal, unit * 0.08)
                    .padding(.vertical, unit * 0.035)
                    .background(VaultPalette.panel.opacity(0.92), in: Capsule())
                    .overlay {
                        Capsule().strokeBorder(VaultPalette.panelStroke, lineWidth: 1)
                    }
                }
            }
            .padding(.bottom, unit * 0.06)
        }
        .opacity(cost == nil ? 0.5 : 1)
    }

    private var emptyBody: some View {
        ZStack(alignment: .bottom) {
            PedestalArt(look: .empty)
                .frame(width: unit, height: unit * 0.4)

            Image(systemName: "plus")
                .font(.system(size: unit * 0.2, weight: .heavy))
                .foregroundStyle(VaultPalette.textOnGold)
                .frame(width: unit * 0.38, height: unit * 0.38)
                .background(VaultPalette.goldGradient, in: Circle())
                .overlay {
                    Circle().strokeBorder(VaultPalette.goldLight.opacity(0.8), lineWidth: 1)
                }
                .padding(.bottom, unit * 0.3)
        }
    }

    private func itemBody(_ item: PlacedItem, canUpgrade: Bool) -> some View {
        ZStack(alignment: .bottom) {
            PedestalArt(look: .occupied)
                .frame(width: unit, height: unit * 0.4)

            ItemArtView(kind: item.kind)
                .frame(width: unit * 0.86, height: unit * 0.86)
                .padding(.bottom, unit * 0.22)

            Text("Lv \(item.level)")
                .font(VaultFont.scene(unit * 0.13))
                .foregroundStyle(VaultPalette.goldLight)
                .padding(.horizontal, unit * 0.07)
                .padding(.vertical, unit * 0.02)
                .background(VaultPalette.panel.opacity(0.92), in: Capsule())
        }
        .overlay(alignment: .topTrailing) {
            if canUpgrade {
                Image(systemName: "arrow.up")
                    .font(.system(size: unit * 0.14, weight: .heavy))
                    .foregroundStyle(VaultPalette.textOnGold)
                    .frame(width: unit * 0.27, height: unit * 0.27)
                    .background(VaultPalette.goldGradient, in: Circle())
                    .padding(.top, unit * 0.04)
            }
        }
    }

    // MARK: Accessibility

    private var accessibilityText: String {
        switch content {
        case .locked(let cost):
            guard let cost else { return "Buried pedestal \(number)" }
            return "Buried pedestal \(number), costs \(CoinFormatter.short(cost)) coins to dig out"
        case .empty:
            return "Empty pedestal \(number)"
        case .item(let item, let canUpgrade):
            let name = ItemCatalog.spec(for: item.kind).name
            return "\(name), level \(item.level)" + (canUpgrade ? ", upgrade available" : "")
        }
    }

    private var accessibilityHintText: String {
        switch content {
        case .locked: "Opens digging"
        case .empty: "Opens the list of treasures to place"
        case .item: "Opens upgrade options"
        }
    }
}
