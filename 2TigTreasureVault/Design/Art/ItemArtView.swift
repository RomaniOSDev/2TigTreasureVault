//
//  ItemArtView.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

/// Picks the drawing for an item kind. Always square.
struct ItemArtView: View {
    let kind: VaultItemKind

    var body: some View {
        Group {
            switch kind {
            case .woodenChest: ChestArt(style: .oak)
            case .torch: TorchArt()
            case .coinPile: CoinPileArt()
            case .brazier: BrazierArt()
            case .goldChest: ChestArt(style: .gilded)
            case .guardianStatue: GuardianStatueArt()
            case .gemCluster: GemClusterArt()
            case .tigerStatue: TigerStatueArt()
            case .crownPedestal: CrownPedestalArt()
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityHidden(true)
    }
}

#Preview {
    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
        ForEach(VaultItemKind.allCases) { kind in
            ItemArtView(kind: kind)
        }
    }
    .padding()
    .background(VaultPalette.caveShadow)
}
