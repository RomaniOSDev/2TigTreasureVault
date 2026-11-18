//
//  VaultStore.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import Foundation
import Observation

struct AwayReport: Identifiable, Equatable {
    let id = UUID()
    let seconds: Double
    let coins: Double
}

struct VaultNotice: Identifiable, Equatable {
    enum Tone {
        case good
        case bad
    }

    let id = UUID()
    let text: String
    let tone: Tone
}

/// Single source of truth for the game. Views read it and call its actions.
@Observable
final class VaultStore {
    // MARK: State

    private(set) var coins: Double
    private(set) var lifetimeCoins: Double
    private(set) var slots: [VaultSlot]
    private(set) var stats: VaultStats
    private(set) var claimedGoals: Set<String>
    private(set) var bestRank: VaultRank
    /// Thieves are waiting at the gate. Income is on hold until they are dealt with.
    private(set) var isUnderSiege: Bool

    var activeRaid: RaidPlan?
    var awayReport: AwayReport?
    var notice: VaultNotice?

    /// Quiet time left before the next raid. Only runs once raids are unlocked.
    private(set) var secondsUntilRaid: Double

    @ObservationIgnored private var lastTick: Date
    @ObservationIgnored private var lastPersist: Date
    @ObservationIgnored private let persistence: VaultPersistence

    init(persistence: VaultPersistence = VaultPersistence(), now: Date = Date()) {
        let save = persistence.load() ?? .fresh(now: now)
        self.persistence = persistence
        coins = save.coins
        lifetimeCoins = save.lifetimeCoins
        slots = Self.normalized(save.slots)
        stats = save.stats
        claimedGoals = save.claimedGoals
        bestRank = VaultRank(rawValue: save.bestRank) ?? .dustyHollow
        isUnderSiege = save.isUnderSiege
        secondsUntilRaid = min(save.secondsUntilRaid, Economy.raidInterval.upperBound)
        lastTick = now
        lastPersist = now

        collectAwayEarnings(seconds: now.timeIntervalSince(save.lastActive))
    }

    // MARK: Derived values

    var incomePerSecond: Double {
        Economy.income(of: slots) * rank.incomeMultiplier
    }

    var beauty: Int { Economy.beauty(of: slots) }
    var safety: Int { Economy.safety(of: slots) }
    var prestige: Int { beauty + safety }
    var rank: VaultRank { VaultRank.rank(forPrestige: prestige) }

    /// 0...1 toward the next rank. Stays at 1 on the top rank.
    var rankProgress: Double {
        guard let next = rank.next else { return 1 }
        let span = next.threshold - rank.threshold
        return Double(prestige - rank.threshold) / Double(span)
    }

    var placedItemCount: Int {
        slots.count { $0.item != nil }
    }

    var openPedestalCount: Int {
        slots.count { $0.isUnlocked }
    }

    /// Pedestals are dug out in order.
    var nextLockedSlot: Int? {
        slots.firstIndex { !$0.isUnlocked }
    }

    /// Thieves leave a small, poor vault alone.
    var raidsUnlocked: Bool {
        lifetimeCoins >= Economy.raidUnlockLifetimeCoins && placedItemCount >= Economy.raidUnlockItems
    }

    var raidLevel: Int { stats.raidsFaced + 1 }
    var isBossRaidNext: Bool { RaidPlanner.isBossRaid(level: raidLevel) }
    var raidPowers: Set<RaidPower> { RaidPlanner.powers(for: slots) }
    var raidToll: Double { RaidPlanner.toll(coins: coins, safety: safety) }
    var tapDamage: Int { RaidPlanner.tapDamage(safety: safety) }

    var lootProtectionPercent: Int {
        Int((RaidPlanner.mitigation(safety: safety) * 100).rounded())
    }

    var claimableGoalCount: Int {
        GoalCatalog.all.count { isComplete($0) && !isClaimed($0) }
    }

    // MARK: Building

    func canAfford(_ cost: Double) -> Bool {
        coins >= cost
    }

    func ownedCount(of kind: VaultItemKind) -> Int {
        slots.count { $0.item?.kind == kind }
    }

    func purchaseCost(for kind: VaultItemKind) -> Double {
        Economy.purchaseCost(for: kind, owned: ownedCount(of: kind))
    }

    func isAvailable(_ spec: VaultItemSpec) -> Bool {
        bestRank >= spec.requiredRank
    }

    @discardableResult
    func unlockNextSlot() -> Bool {
        guard let index = nextLockedSlot else { return false }
        let cost = Economy.unlockCost(forSlot: index)
        guard canAfford(cost) else { return false }
        coins -= cost
        slots[index].isUnlocked = true
        persist()
        return true
    }

    @discardableResult
    func place(_ kind: VaultItemKind, at index: Int) -> Bool {
        guard slots.indices.contains(index),
              slots[index].isUnlocked,
              slots[index].item == nil,
              isAvailable(ItemCatalog.spec(for: kind)) else { return false }
        let cost = purchaseCost(for: kind)
        guard canAfford(cost) else { return false }

        trackingRank {
            coins -= cost
            slots[index].item = PlacedItem(kind: kind, level: 1, invested: cost)
        }
        persist()
        return true
    }

    @discardableResult
    func upgrade(at index: Int) -> Bool {
        guard slots.indices.contains(index),
              let item = slots[index].item,
              item.level < Economy.maxLevel else { return false }
        let cost = Economy.upgradeCost(for: item)
        guard canAfford(cost) else { return false }

        trackingRank {
            coins -= cost
            slots[index].item?.level += 1
            slots[index].item?.invested += cost
        }
        persist()
        return true
    }

    func remove(at index: Int) {
        guard slots.indices.contains(index), let item = slots[index].item else { return }
        coins += Economy.refund(for: item)
        slots[index].item = nil
        persist()
    }

    // MARK: Goals

    func value(for metric: GoalMetric) -> Double {
        switch metric {
        case .itemsPlaced: Double(placedItemCount)
        case .incomePerSecond: incomePerSecond
        case .pedestalsOpen: Double(openPedestalCount)
        case .prestige: Double(prestige)
        case .thievesRepelled: Double(stats.thievesRepelled)
        case .flawlessRaids: Double(stats.flawlessRaids)
        case .bestCombo: Double(stats.bestCombo)
        case .bossesDefeated: Double(stats.bossesDefeated)
        case .lifetimeCoins: lifetimeCoins
        case .highestItemLevel: Double(slots.compactMap { $0.item?.level }.max() ?? 0)
        case .owns(let kind): Double(ownedCount(of: kind))
        }
    }

    func progress(of goal: VaultGoal) -> Double {
        min(1, value(for: goal.metric) / goal.target)
    }

    func isComplete(_ goal: VaultGoal) -> Bool {
        value(for: goal.metric) >= goal.target
    }

    func isClaimed(_ goal: VaultGoal) -> Bool {
        claimedGoals.contains(goal.id)
    }

    func claim(_ goal: VaultGoal) {
        guard isComplete(goal), !isClaimed(goal) else { return }
        claimedGoals.insert(goal.id)
        earn(goal.reward)
        persist()
    }

    // MARK: Raids

    func beginRaid() {
        guard isUnderSiege, activeRaid == nil else { return }
        activeRaid = RaidPlanner.makePlan(
            level: raidLevel,
            coins: coins,
            incomePerSecond: incomePerSecond,
            safety: safety,
            slots: slots
        )
    }

    /// The keeper does not have to wait: lure the next raid in right now.
    func callRaid() {
        guard raidsUnlocked, !isUnderSiege, activeRaid == nil else { return }
        isUnderSiege = true
        beginRaid()
    }

    /// Skip the fight for a price.
    func payToll() {
        guard isUnderSiege, activeRaid == nil else { return }
        let toll = min(coins, raidToll)
        coins -= toll
        stats.coinsStolen += toll
        stats.raidsFaced += 1
        endSiege()
        notice = VaultNotice(
            text: toll >= 1
                ? "The thieves left with \(CoinFormatter.short(toll)) coins."
                : "The thieves found nothing worth taking.",
            tone: .bad
        )
        persist()
    }

    func completeRaid(_ outcome: RaidOutcome) {
        earn(outcome.bounty)
        let lost = min(coins, outcome.stolen)
        coins -= lost

        stats.raidsFaced += 1
        stats.thievesRepelled += outcome.repelled
        stats.coinsStolen += lost
        stats.bestCombo = max(stats.bestCombo, outcome.bestCombo)
        stats.bossesDefeated += outcome.bossesDefeated
        if outcome.isFlawless {
            stats.flawlessRaids += 1
        }

        activeRaid = nil
        endSiege()
        persist()
    }

    // MARK: Time

    /// Called a few times per second while the app is on screen.
    func tick(now: Date = Date()) {
        let elapsed = now.timeIntervalSince(lastTick)
        lastTick = now
        guard elapsed > 0 else { return }

        // The timer stops in the background, so a long gap means the player was away.
        if elapsed > 20 {
            collectAwayEarnings(seconds: elapsed)
            persist(now: now)
            return
        }

        if !isUnderSiege {
            earn(incomePerSecond * elapsed)
            advanceRaidClock(by: elapsed)
        }

        if now.timeIntervalSince(lastPersist) > 8 {
            persist(now: now)
        }
    }

    func persist(now: Date = Date()) {
        lastPersist = now
        persistence.store(
            VaultSave(
                coins: coins,
                lifetimeCoins: lifetimeCoins,
                slots: slots,
                stats: stats,
                claimedGoals: claimedGoals,
                bestRank: bestRank.rawValue,
                secondsUntilRaid: secondsUntilRaid,
                isUnderSiege: isUnderSiege,
                lastActive: now
            )
        )
    }

    func resetProgress(now: Date = Date()) {
        let save = VaultSave.fresh(now: now)
        coins = save.coins
        lifetimeCoins = save.lifetimeCoins
        slots = save.slots
        stats = save.stats
        claimedGoals = save.claimedGoals
        bestRank = .dustyHollow
        isUnderSiege = false
        secondsUntilRaid = save.secondsUntilRaid
        activeRaid = nil
        awayReport = nil
        notice = nil
        lastTick = now
        persist(now: now)
    }

    // MARK: Private

    private func earn(_ amount: Double) {
        guard amount > 0 else { return }
        coins += amount
        lifetimeCoins += amount
    }

    private func advanceRaidClock(by elapsed: Double) {
        guard raidsUnlocked else { return }
        secondsUntilRaid -= elapsed
        if secondsUntilRaid <= 0 {
            isUnderSiege = true
        }
    }

    private func endSiege() {
        isUnderSiege = false
        secondsUntilRaid = Double.random(in: Economy.raidInterval)
    }

    /// Nobody was home to defend: the thieves helped themselves and left.
    private func settleUnattendedSiege() {
        let toll = min(coins, raidToll)
        coins -= toll
        stats.coinsStolen += toll
        stats.raidsFaced += 1
        activeRaid = nil
        endSiege()
        if toll >= 1 {
            notice = VaultNotice(
                text: "While you were away, thieves took \(CoinFormatter.short(toll)) coins.",
                tone: .bad
            )
        }
    }

    private func collectAwayEarnings(seconds: Double) {
        let income = incomePerSecond
        guard seconds > 0 else { return }

        guard seconds >= Economy.awayThreshold else {
            // A besieged vault earns nothing while the thieves are still at the gate.
            if !isUnderSiege {
                earn(income * seconds)
            }
            return
        }

        if isUnderSiege {
            // Mid-fight the raid screen is still up, so the keeper gets to finish it.
            guard activeRaid == nil else { return }
            settleUnattendedSiege()
        }

        let counted = min(seconds, Economy.awayCap)
        let earned = (income * counted * Economy.awayRate).rounded(.down)
        guard earned >= 1 else { return }
        earn(earned)
        awayReport = AwayReport(seconds: counted, coins: earned)
    }

    /// Runs a change to the pedestals and announces a rank the vault has never held before.
    private func trackingRank(_ change: () -> Void) {
        change()
        let current = rank
        guard current > bestRank else { return }
        bestRank = current
        notice = VaultNotice(text: "Your vault is now a \(current.name).", tone: .good)
    }

    private static func normalized(_ slots: [VaultSlot]) -> [VaultSlot] {
        var result = Array(slots.prefix(Economy.slotCount))
        while result.count < Economy.slotCount {
            result.append(VaultSlot(isUnlocked: result.count < Economy.initiallyOpenSlots, item: nil))
        }
        return result
    }
}
