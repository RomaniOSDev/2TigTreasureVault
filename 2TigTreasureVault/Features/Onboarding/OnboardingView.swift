//
//  OnboardingView.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

/// Three-page introduction. Also reused from Settings as the "How to play" guide.
struct OnboardingView: View {
    var finishTitle = "Start building"
    var skipTitle = "Skip"
    let onFinish: () -> Void

    @State private var page = 0

    private let pages = OnboardingPage.all

    private var isLastPage: Bool { page == pages.count - 1 }

    var body: some View {
        ZStack {
            VaultBackgroundView()

            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Button(skipTitle, action: onFinish)
                        .font(VaultFont.body(.subheadline, weight: .semibold))
                        .foregroundStyle(VaultPalette.textSecondary)
                        .frame(minWidth: 44, minHeight: 44)
                        .opacity(isLastPage ? 0 : 1)
                        .disabled(isLastPage)
                }

                TabView(selection: $page) {
                    ForEach(pages) { item in
                        OnboardingPageView(page: item)
                            .tag(item.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                HStack(spacing: 8) {
                    ForEach(pages) { item in
                        Capsule()
                            .fill(item.id == page ? VaultPalette.gold : VaultPalette.textMuted.opacity(0.4))
                            .frame(width: item.id == page ? 22 : 8, height: 8)
                    }
                }
                .animation(.snappy(duration: 0.25), value: page)
                .accessibilityElement()
                .accessibilityLabel("Page \(page + 1) of \(pages.count)")

                Button(isLastPage ? finishTitle : "Next") {
                    if isLastPage {
                        onFinish()
                    } else {
                        withAnimation(.snappy(duration: 0.3)) {
                            page += 1
                        }
                    }
                }
                .buttonStyle(GoldButtonStyle())
            }
            .padding(.horizontal, VaultMetrics.screenPadding)
            .padding(.bottom, 16)
        }
    }
}

private struct OnboardingPage: Identifiable {
    enum Scene {
        case build
        case earn
        case defend
    }

    let id: Int
    let scene: Scene
    let title: String
    let text: String

    static let all = [
        OnboardingPage(
            id: 0,
            scene: .build,
            title: "Furnish your cave",
            text: "Dig out pedestals and fill them with chests, torches and statues. Every piece makes the vault more beautiful or more secure."
        ),
        OnboardingPage(
            id: 1,
            scene: .earn,
            title: "Let the gold flow",
            text: "Treasures earn coins on their own, even while you are away. Upgrade them and climb the ranks for a bigger income."
        ),
        OnboardingPage(
            id: 2,
            scene: .defend,
            title: "Guard the gate",
            text: "Thieves and cave monsters raid your hoard in waves. Tap them before they reach the gold and chain kills for a bigger bounty. Torches, guardians and the tiger give you powers to turn the fight."
        )
    ]
}

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 0)

            illustration
                .frame(maxWidth: 320)
                .frame(height: 240)

            VStack(spacing: 12) {
                Text(page.title)
                    .font(VaultFont.title(.largeTitle))
                    .foregroundStyle(VaultPalette.textPrimary)
                    .multilineTextAlignment(.center)
                Text(page.text)
                    .font(VaultFont.body(.body))
                    .foregroundStyle(VaultPalette.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 8)
    }

    @ViewBuilder
    private var illustration: some View {
        switch page.scene {
        case .build:
            HStack(alignment: .bottom, spacing: -6) {
                staged(.torch, size: 96)
                staged(.woodenChest, size: 128)
                staged(.coinPile, size: 96)
            }
        case .earn:
            staged(.tigerStatue, size: 220)
        case .defend:
            HStack(alignment: .bottom, spacing: 4) {
                ThiefArt(kind: .bat).frame(width: 84, height: 84)
                    .padding(.bottom, 60)
                ThiefArt(kind: .skeleton).frame(width: 132, height: 132)
                ThiefArt(kind: .slime).frame(width: 96, height: 96)
            }
            .accessibilityHidden(true)
        }
    }

    private func staged(_ kind: VaultItemKind, size: CGFloat) -> some View {
        ZStack(alignment: .bottom) {
            PedestalArt(look: .occupied)
                .frame(width: size, height: size * 0.4)
            ItemArtView(kind: kind)
                .frame(width: size * 0.86, height: size * 0.86)
                .padding(.bottom, size * 0.22)
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    OnboardingView {}
}
