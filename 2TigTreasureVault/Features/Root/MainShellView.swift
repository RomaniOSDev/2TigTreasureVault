//
//  MainShellView.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

/// Tabs, the floating tab bar, and everything that has to sit above all tabs:
/// raid alerts, short notices, the welcome-back card and the raid itself.
struct MainShellView: View {
    @Environment(VaultStore.self) private var store
    @State private var tab: VaultTab = .vault

    var body: some View {
        @Bindable var store = store

        ZStack {
            switch tab {
            case .vault: VaultScreen()
            case .goals: GoalsScreen()
            case .ledger: LedgerScreen()
            case .settings: SettingsScreen()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .bottom) {
            // Scrolled content fades out behind the bar instead of peeking out under it.
            LinearGradient(
                stops: [
                    .init(color: VaultPalette.caveDeep.opacity(0), location: 0),
                    .init(color: VaultPalette.caveDeep, location: 0.45),
                    .init(color: VaultPalette.caveDeep, location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .bottom)
            .frame(height: VaultMetrics.tabBarClearance)
            .allowsHitTesting(false)
        }
        .overlay(alignment: .bottom) {
            VStack(spacing: 10) {
                if let notice = store.notice {
                    NoticeToast(notice: notice)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                if store.isUnderSiege {
                    RaidAlertBanner(
                        isBoss: store.isBossRaidNext,
                        toll: store.raidToll,
                        onDefend: store.beginRaid,
                        onPay: store.payToll
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                VaultTabBar(
                    selection: $tab,
                    badgedTab: store.claimableGoalCount > 0 ? .goals : nil
                )
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 4)
            .animation(.snappy(duration: 0.3), value: store.isUnderSiege)
            .animation(.snappy(duration: 0.3), value: store.notice)
        }
        .overlay {
            if let report = store.awayReport {
                AwayEarningsCard(report: report) {
                    store.awayReport = nil
                }
                .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.25), value: store.awayReport)
        .fullScreenCover(item: $store.activeRaid) { plan in
            RaidScreen(plan: plan)
        }
        .task(id: store.notice) {
            guard store.notice != nil else { return }
            try? await Task.sleep(for: .seconds(3.5))
            guard !Task.isCancelled else { return }
            store.notice = nil
        }
    }
}

#Preview {
    MainShellView()
        .environment(VaultStore())
        .environment(AppSettings())
}
