//
//  VaultScreen.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import SwiftUI

/// The cave: a HUD on top and the pedestals below it.
struct VaultScreen: View {
    @Environment(VaultStore.self) private var store
    @State private var sheet: VaultSheet?

    var body: some View {
        ZStack {
            CaveBackdrop()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                VaultHUDView()
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                RaidTimerChip(
                    phase: raidPhase,
                    level: store.raidLevel,
                    isBoss: store.isBossRaidNext,
                    onFight: store.callRaid
                )
                .padding(.horizontal, 16)
                .padding(.top, 8)

                CaveSceneView(onTapSlot: openSlot)
                    .padding(.top, 6)
                    .padding(.bottom, VaultMetrics.tabBarClearance - 14)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(item: $sheet) { sheet in
            switch sheet {
            case .build(let index):
                BuildSheet(slotIndex: index)
            case .item(let index):
                ItemDetailSheet(slotIndex: index)
            case .dig:
                DigSheet()
            }
        }
    }

    private var raidPhase: RaidTimerChip.Phase {
        if store.isUnderSiege { return .atTheGate }
        return store.raidsUnlocked ? .counting(seconds: store.secondsUntilRaid) : .quiet
    }

    private func openSlot(_ index: Int) {
        guard store.slots.indices.contains(index) else { return }
        let slot = store.slots[index]
        Haptics.tap()

        if !slot.isUnlocked {
            sheet = .dig
        } else if slot.item == nil {
            sheet = .build(index)
        } else {
            sheet = .item(index)
        }
    }
}

private enum VaultSheet: Identifiable {
    case build(Int)
    case item(Int)
    case dig

    var id: String {
        switch self {
        case .build(let index): "build-\(index)"
        case .item(let index): "item-\(index)"
        case .dig: "dig"
        }
    }
}

#Preview {
    VaultScreen()
        .environment(VaultStore())
        .environment(AppSettings())
}
