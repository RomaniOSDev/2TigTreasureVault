//
//  SheetScaffold.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

/// Common frame for bottom sheets: title, close button, scrolling body on the vault background.
struct SheetScaffold<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder var content: Content

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            VaultBackgroundView()

            ScrollView {
                VStack(alignment: .leading, spacing: VaultMetrics.stackSpacing) {
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(title)
                                .font(VaultFont.title(.title2))
                                .foregroundStyle(VaultPalette.textPrimary)
                                .accessibilityAddTraits(.isHeader)
                            Text(subtitle)
                                .font(VaultFont.body(.subheadline))
                                .foregroundStyle(VaultPalette.textSecondary)
                        }

                        Spacer(minLength: 0)

                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(VaultPalette.textSecondary)
                                .frame(width: 44, height: 44)
                                .background(VaultPalette.panelRaised, in: Circle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Close")
                    }

                    content
                }
                .padding(.horizontal, VaultMetrics.screenPadding)
                .padding(.top, 24)
                .padding(.bottom, 28)
            }
            .clearScrollBackground()
        }
        .presentationDragIndicator(.visible)
        .presentationBackground(VaultPalette.caveShadow)
    }
}
