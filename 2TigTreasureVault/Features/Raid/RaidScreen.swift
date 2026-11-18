//
//  RaidScreen.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import Combine
import SwiftUI

/// Full-screen defense: monsters come from the gate in waves, the player taps them away
/// and fires the powers the vault's treasures grant.
struct RaidScreen: View {
    @Environment(VaultStore.self) private var store
    @State private var model: RaidViewModel
    @State private var isConfirmingRetreat = false

    private let frameClock = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()
    private let hoardHeight: CGFloat = 132

    init(plan: RaidPlan) {
        _model = State(initialValue: RaidViewModel(plan: plan))
    }

    var body: some View {
        // The outer reader only exists to learn the bottom inset: the playfield is full-bleed,
        // but has to end where the hoard stands above the safe area.
        GeometryReader { proxy in
            let bottomInset = proxy.safeAreaInsets.bottom

            // Full-bleed layers ignore the safe area one by one, so the overlays below still respect it.
            ZStack {
                CaveBackdrop(mood: .raid)
                    .ignoresSafeArea()

                GeometryReader { geo in
                    playfield(in: geo.size, bottomInset: bottomInset)
                }
                .ignoresSafeArea()

                PowerFlash(blast: model.blast)
                    .ignoresSafeArea()

                BreachFlash(trigger: model.breachCount)
                    .ignoresSafeArea()
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .overlay(alignment: .bottom) {
                VStack(spacing: 0) {
                    hoard
                    RaidPowerBar(
                        unlocked: model.plan.powers,
                        cooldownFraction: model.cooldownFraction,
                        isActive: model.phase == .fighting,
                        onUse: model.use
                    )
                    .opacity(model.phase == .finished ? 0 : 1)
                }
            }
            .overlay(alignment: .top) {
                if model.phase != .finished {
                    VStack(spacing: 8) {
                        RaidHUDView(
                            level: model.plan.level,
                            wave: model.wave,
                            waveCount: model.plan.waveCount,
                            remaining: model.remaining,
                            bounty: model.bounty,
                            stolen: model.stolen
                        ) {
                            isConfirmingRetreat = true
                        }

                        if model.combo >= 2 {
                            ComboBadge(combo: model.combo)
                                .transition(.scale(scale: 0.8).combined(with: .opacity))
                        }
                    }
                    .animation(.snappy(duration: 0.2), value: model.combo >= 2)
                }
            }
            .overlay {
                if model.phase == .countdown {
                    RaidCountdownView(seconds: model.countdown, plan: model.plan)
                        .transition(.opacity)
                }
            }
            .overlay {
                if model.phase == .finished {
                    RaidResultView(outcome: model.outcome) {
                        store.completeRaid(model.outcome)
                    }
                    .transition(.opacity)
                }
            }
        }
        .animation(.easeOut(duration: 0.25), value: model.phase)
        .onReceive(frameClock) { now in
            model.step(now: now)
        }
        .onChange(of: isConfirmingRetreat) { _, isShowing in
            model.isPaused = isShowing
        }
        .confirmationDialog("Abandon the gate?", isPresented: $isConfirmingRetreat, titleVisibility: .visible) {
            Button("Retreat", role: .destructive) {
                model.retreat()
            }
            Button("Keep fighting", role: .cancel) {}
        } message: {
            Text("Every monster still out there will walk off with loot.")
        }
    }

    // MARK: Playfield

    private func playfield(in size: CGSize, bottomInset: CGFloat) -> some View {
        let gateY = size.height * 0.31
        // Monsters stop where the hoard begins.
        let hoardY = size.height - bottomInset - RaidPowerBar.height - hoardHeight + 34
        let travel = hoardY - gateY
        let baseSize = min(size.width * 0.25, 104)

        /// Depth: things near the gate are drawn smaller.
        func depth(_ progress: Double) -> CGFloat {
            0.68 + 0.47 * progress
        }

        func point(_ spot: RaidViewModel.Spot) -> CGPoint {
            CGPoint(
                x: spot.x * size.width,
                y: gateY + travel * spot.progress - spot.lift * baseSize * depth(spot.progress)
            )
        }

        return ZStack {
            ForEach(model.thieves) { thief in
                let scale = depth(thief.progress) * thief.kind.sizeScale

                ThiefView(thief: thief, baseSize: baseSize, isFrozen: model.isFrozen) {
                    model.hit(thief.id)
                }
                .scaleEffect(scale)
                .position(
                    x: thief.x * size.width,
                    y: gateY + travel * thief.progress - thief.kind.lift * baseSize * scale
                )
                .zIndex(thief.progress)
            }

            ForEach(model.sparks) { spark in
                SparkView(life: spark.age / RaidViewModel.sparkDuration)
                    .position(point(spark.spot))
                    .zIndex(2)
            }

            ForEach(model.floaters) { floater in
                let life = floater.age / RaidViewModel.floaterDuration
                let origin = point(floater.spot)

                Text(floater.text)
                    .font(VaultFont.scene(20))
                    .foregroundStyle(floater.isLoss ? VaultPalette.danger : VaultPalette.goldLight)
                    .shadow(color: .black.opacity(0.8), radius: 2, y: 1)
                    .opacity(1 - life)
                    .position(x: origin.x, y: origin.y - 46 - life * 44)
                    .zIndex(3)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }

            if model.phase == .fighting, let banner = model.banner {
                // Up in the mouth of the gate, where it never covers a monster worth tapping.
                RaidBannerView(banner: banner)
                    .position(x: size.width / 2, y: size.height * 0.245)
                    .zIndex(4)
            }
        }
    }

    /// The gold the monsters are after. Purely decorative, never blocks taps. Jolts when it is robbed.
    private var hoard: some View {
        HStack(alignment: .bottom, spacing: -30) {
            CoinPileArt().frame(width: 104, height: 104)
            ChestArt(style: .gilded).frame(width: hoardHeight, height: hoardHeight)
            CoinPileArt().frame(width: 104, height: 104)
        }
        .keyframeAnimator(initialValue: CGFloat.zero, trigger: model.breachCount) { content, shift in
            content.offset(x: shift)
        } keyframes: { _ in
            LinearKeyframe(9, duration: 0.05)
            LinearKeyframe(-8, duration: 0.09)
            LinearKeyframe(5, duration: 0.08)
            LinearKeyframe(0, duration: 0.08)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

private extension ThiefKind {
    var sizeScale: CGFloat {
        switch self {
        case .skeleton, .ghost: 1
        case .runner: 0.84
        case .bat: 0.8
        case .slime: 0.95
        case .slimeling: 0.58
        case .brute: 1.3
        case .boneKing: 1.75
        }
    }
}
