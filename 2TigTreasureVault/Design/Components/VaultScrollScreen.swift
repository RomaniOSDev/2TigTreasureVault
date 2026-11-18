//
//  VaultScrollScreen.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

/// Shell for scrolling tab roots: background, title, and tab bar clearance in one place.
struct VaultScrollScreen<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            VaultBackgroundView()

            ScrollView {
                VStack(alignment: .leading, spacing: VaultMetrics.stackSpacing) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(title)
                            .font(VaultFont.title(.largeTitle))
                            .foregroundStyle(VaultPalette.textPrimary)
                            .accessibilityAddTraits(.isHeader)
                        Text(subtitle)
                            .font(VaultFont.body(.subheadline))
                            .foregroundStyle(VaultPalette.textSecondary)
                    }

                    content
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, VaultMetrics.screenPadding)
                .padding(.top, 16)
                .padding(.bottom, VaultMetrics.tabBarClearance)
            }
            .clearScrollBackground()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Small caps heading between groups of panels.
struct SectionHeading: View {
    let text: String

    var body: some View {
        Text(text.uppercased())
            .font(VaultFont.body(.footnote, weight: .bold))
            .kerning(1.2)
            .foregroundStyle(VaultPalette.textMuted)
            .accessibilityAddTraits(.isHeader)
    }
}
