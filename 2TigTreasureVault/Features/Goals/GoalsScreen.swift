//
//  GoalsScreen.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

/// One-time milestones with coin rewards.
struct GoalsScreen: View {
    @Environment(VaultStore.self) private var store

    /// Rewards ready to claim first, then work in progress, then finished goals.
    private var orderedGoals: [VaultGoal] {
        func group(_ goal: VaultGoal) -> Int {
            if store.isClaimed(goal) { return 2 }
            return store.isComplete(goal) ? 0 : 1
        }
        return GoalCatalog.all.enumerated()
            .sorted { lhs, rhs in
                let left = group(lhs.element)
                let right = group(rhs.element)
                return left == right ? lhs.offset < rhs.offset : left < right
            }
            .map(\.element)
    }

    var body: some View {
        let total = GoalCatalog.all.count
        let claimed = store.claimedGoals.count

        VaultScrollScreen(title: "Goals", subtitle: "Milestones for a keeper on the rise.") {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Completed")
                        .font(VaultFont.body(.subheadline, weight: .medium))
                        .foregroundStyle(VaultPalette.textSecondary)
                    Spacer()
                    Text("\(claimed) of \(total)")
                        .font(VaultFont.number(.subheadline))
                        .foregroundStyle(VaultPalette.textPrimary)
                }
                VaultProgressBar(value: Double(claimed) / Double(max(1, total)))
            }
            .vaultPanel()
            .accessibilityElement(children: .combine)

            ForEach(orderedGoals) { goal in
                GoalRow(
                    goal: goal,
                    value: store.value(for: goal.metric),
                    isComplete: store.isComplete(goal),
                    isClaimed: store.isClaimed(goal)
                ) {
                    withAnimation(.snappy(duration: 0.3)) {
                        store.claim(goal)
                    }
                    Haptics.success()
                }
            }
        }
    }
}

private struct GoalRow: View {
    let goal: VaultGoal
    let value: Double
    let isComplete: Bool
    let isClaimed: Bool
    let onClaim: () -> Void

    private var progressText: String {
        let shown = min(value, goal.target)
        return "\(CoinFormatter.short(shown)) / \(CoinFormatter.short(goal.target))"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(goal.title)
                        .font(VaultFont.title(.headline))
                        .foregroundStyle(isClaimed ? VaultPalette.textSecondary : VaultPalette.textPrimary)
                    Text(goal.detail)
                        .font(VaultFont.body(.footnote))
                        .foregroundStyle(VaultPalette.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                if isClaimed {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(VaultPalette.safety)
                        .accessibilityLabel("Claimed")
                } else {
                    CoinLabel(amount: goal.reward, prefix: "+")
                        .foregroundStyle(VaultPalette.gold)
                }
            }

            if isClaimed {
                EmptyView()
            } else if isComplete {
                Button("Claim reward", action: onClaim)
                    .buttonStyle(GoldButtonStyle())
            } else {
                HStack(spacing: 10) {
                    VaultProgressBar(value: value / goal.target)
                    Text(progressText)
                        .font(VaultFont.number(.caption))
                        .foregroundStyle(VaultPalette.textSecondary)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Progress \(progressText)")
            }
        }
        .vaultPanel(stroke: isComplete && !isClaimed ? VaultPalette.gold.opacity(0.6) : VaultPalette.panelStroke)
        .opacity(isClaimed ? 0.7 : 1)
    }
}

#Preview {
    GoalsScreen()
        .environment(VaultStore())
}
