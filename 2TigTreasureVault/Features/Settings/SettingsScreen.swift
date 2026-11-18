//
//  SettingsScreen.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import StoreKit
import SwiftUI
import UIKit

struct SettingsScreen: View {
    @Environment(VaultStore.self) private var store
    @Environment(AppSettings.self) private var settings

    @State private var isShowingGuide = false
    @State private var isConfirmingReset = false

    private var versionText: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        return "Version \(version ?? "1.0")"
    }

    var body: some View {
        @Bindable var settings = settings

        VaultScrollScreen(title: "Settings", subtitle: "Tune the vault to your liking.") {
            SectionHeading(text: "Feel")
            Toggle(isOn: $settings.hapticsEnabled) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Haptics")
                        .font(VaultFont.body(.body, weight: .semibold))
                        .foregroundStyle(VaultPalette.textPrimary)
                    Text("Feel taps, hits and rewards.")
                        .font(VaultFont.body(.footnote))
                        .foregroundStyle(VaultPalette.textSecondary)
                }
            }
            .tint(VaultPalette.goldDeep)
            .vaultPanel()

            SectionHeading(text: "Help")
            SettingsRow(title: "How to play", symbol: "questionmark.circle.fill") {
                isShowingGuide = true
            }

            SectionHeading(text: "About")
            SettingsRow(title: "Rate Us", symbol: "star.fill", accessory: .none) {
                rateApp()
            }
            SettingsRow(title: "Privacy Policy", symbol: "hand.raised.fill", accessory: .external) {
                open(.privacyPolicy)
            }
            SettingsRow(title: "Terms of Use", symbol: "doc.text.fill", accessory: .external) {
                open(.termsOfUse)
            }

            SectionHeading(text: "Progress")
            VStack(alignment: .leading, spacing: 14) {
                Text("Start over with an empty cave. Coins, treasures, goals and raid history are all erased.")
                    .font(VaultFont.body(.footnote))
                    .foregroundStyle(VaultPalette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                Button("Reset progress") {
                    isConfirmingReset = true
                }
                .buttonStyle(OutlineButtonStyle(tint: VaultPalette.danger))
            }
            .vaultPanel()

            Text(versionText)
                .font(VaultFont.body(.footnote))
                .foregroundStyle(VaultPalette.textMuted)
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
        }
        .sheet(isPresented: $isShowingGuide) {
            OnboardingView(finishTitle: "Got it", skipTitle: "Close") {
                isShowingGuide = false
            }
            .presentationBackground(VaultPalette.caveShadow)
        }
        .confirmationDialog("Reset the whole vault?", isPresented: $isConfirmingReset, titleVisibility: .visible) {
            Button("Erase everything", role: .destructive) {
                store.resetProgress()
                Haptics.warning()
            }
            Button("Keep my vault", role: .cancel) {}
        } message: {
            Text("This cannot be undone.")
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    private func open(_ link: AppLink) {
        if let url = link.url {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    SettingsScreen()
        .environment(VaultStore())
        .environment(AppSettings())
}
