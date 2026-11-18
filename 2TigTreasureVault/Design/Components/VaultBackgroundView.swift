//
//  VaultBackgroundView.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

/// Static backdrop for every screen that is not the cave itself.
struct VaultBackgroundView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [VaultPalette.caveRock, VaultPalette.caveShadow, VaultPalette.caveDeep],
                startPoint: .top,
                endPoint: .bottom
            )

            RadialGradient(
                colors: [VaultPalette.ember.opacity(0.22), .clear],
                center: UnitPoint(x: 0.5, y: 0),
                startRadius: 0,
                endRadius: 420
            )

            RadialGradient(
                colors: [VaultPalette.gold.opacity(0.08), .clear],
                center: UnitPoint(x: 0.1, y: 1),
                startRadius: 0,
                endRadius: 360
            )
        }
        .ignoresSafeArea()
    }
}

extension View {
    /// Lets the custom background show through a scroll view.
    func clearScrollBackground() -> some View {
        scrollContentBackground(.hidden)
            .background(Color.clear)
    }
}

#Preview {
    VaultBackgroundView()
}
