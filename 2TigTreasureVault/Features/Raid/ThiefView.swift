//
//  ThiefView.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

/// A single monster on the playfield. Reacts on touch-down so taps feel immediate.
struct ThiefView: View {
    let thief: RaidViewModel.Thief
    /// Drawn at a fixed size; the parent scales it for depth so the art is never re-rendered.
    let baseSize: CGFloat
    /// Petrified by a power: drained of color and standing still.
    let isFrozen: Bool
    let onHit: () -> Void

    /// Resets by itself when a touch ends or is cancelled, so one touch is always exactly one hit.
    @GestureState private var isTouching = false

    /// 1 while coming, falling to 0 as a defeated monster fades out.
    private var presence: Double {
        guard let age = thief.fadeAge else { return 1 }
        return 1 - min(1, age / RaidViewModel.fadeDuration)
    }

    /// Monsters fade in as they come out of the gate.
    private var emergence: Double {
        min(1, 0.25 + thief.progress * 14)
    }

    /// Each kind moves in its own way. All of it is cheap transforms driven by the monster's age.
    private var gait: Gait {
        let age = thief.age
        switch thief.kind {
        case .skeleton, .brute, .boneKing:
            return Gait(tilt: sin(age * 8) * 4)
        case .runner:
            return Gait(tilt: sin(age * 12) * 6)
        case .bat:
            return Gait(stretchX: 1 + sin(age * 18) * 0.1, bob: sin(age * 6) * 4)
        case .slime, .slimeling:
            let pulse = sin(age * 7)
            return Gait(stretchX: 1 + pulse * 0.07, stretchY: 1 - pulse * 0.07)
        case .ghost:
            return Gait(bob: sin(age * 2.4) * 5)
        }
    }

    var body: some View {
        let gait = gait

        VStack(spacing: 3) {
            if thief.maxHP > 1 {
                VaultProgressBar(
                    value: Double(max(0, thief.hp)) / Double(thief.maxHP),
                    tint: VaultPalette.danger,
                    height: 5
                )
                .frame(width: baseSize * 0.56)
                .opacity(thief.isDefeated ? 0 : 1)
            }

            ThiefArt(kind: thief.kind)
                .frame(width: baseSize, height: baseSize)
                .scaleEffect(x: gait.stretchX, y: gait.stretchY, anchor: .bottom)
                .rotationEffect(.degrees(gait.tilt), anchor: .bottom)
                .offset(y: gait.bob)
                .brightness(thief.flash > 0 ? 0.45 : 0)
                .saturation(isFrozen ? 0.1 : 1)
                // Only the fade is animated; position and gait keep following the frame clock.
                .animation(.easeInOut(duration: 0.22)) { art in
                    art.opacity(thief.isPhased ? 0.28 : 1)
                }
        }
        .background(alignment: .bottom) {
            if thief.kind.lift > 0 {
                // Flyers are drawn above the floor; their shadow stays on it.
                Ellipse()
                    .fill(.black.opacity(0.32))
                    .frame(width: baseSize * 0.5, height: baseSize * 0.1)
                    .offset(y: baseSize * CGFloat(thief.kind.lift))
            }
        }
        .scaleEffect(1 + (1 - presence) * 0.35)
        .opacity(presence * emergence)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .updating($isTouching) { _, isTouching, _ in
                    isTouching = true
                }
        )
        .onChange(of: isTouching) { _, isDown in
            if isDown {
                onHit()
            }
        }
        .allowsHitTesting(!thief.isDefeated && !thief.isPhased)
        .accessibilityElement()
        .accessibilityLabel("\(thief.kind.displayName), \(max(0, thief.hp)) of \(thief.maxHP) health")
        .accessibilityValue(thief.isPhased ? "Out of reach" : "")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction(.default, onHit)
    }
}

private struct Gait {
    /// Degrees of lean around the feet.
    var tilt: Double = 0
    var stretchX: CGFloat = 1
    var stretchY: CGFloat = 1
    /// Points of vertical drift.
    var bob: CGFloat = 0
}
