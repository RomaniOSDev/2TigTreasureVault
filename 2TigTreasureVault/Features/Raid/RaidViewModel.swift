//
//  RaidViewModel.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import Foundation
import Observation

/// Runs one raid: sends monsters in waves, walks them toward the hoard,
/// and scores taps, combos and powers.
@Observable
final class RaidViewModel {
    enum Phase {
        case countdown
        case fighting
        case finished
    }

    struct Thief: Identifiable {
        let id: Int
        let kind: ThiefKind
        /// Where it is heading, 0...1 across the cave.
        let lane: Double
        let maxHP: Int
        var hp: Int
        /// 0 at the gate, 1 at the hoard.
        var progress: Double = 0
        /// Seconds it has been on the move. Petrified monsters do not age, so their motion stops too.
        var age: Double = 0
        /// Seconds of hit flash left.
        var flash: Double = 0
        /// Seconds since it was defeated. `nil` while it is still coming.
        var fadeAge: Double?

        var isDefeated: Bool { fadeAge != nil }

        /// Ghosts drift in and out of reach. Taps pass straight through a faded one.
        var isPhased: Bool {
            guard kind == .ghost, !isDefeated else { return false }
            let cycle = (age + Double(id % 5) * 0.45).truncatingRemainder(dividingBy: 2.8)
            return cycle > 1.7
        }

        /// Horizontal position, 0...1 across the cave. Monsters pour out of the narrow gate,
        /// fan out to their lanes and drift from side to side on the way.
        var x: Double {
            let gateLane = 0.5 + (lane - 0.5) * 0.4
            let spread = min(1, progress / 0.35)
            let eased = spread * spread * (3 - 2 * spread)
            let sway = sin(age * kind.swaySpeed + Double(id)) * kind.swayWidth * (0.4 + 0.6 * eased)
            return min(0.92, max(0.08, gateLane + (lane - gateLane) * eased + sway))
        }
    }

    /// A spot on the playfield, remembered so effects stay where something happened.
    struct Spot {
        let x: Double
        let progress: Double
        let lift: Double

        init(_ thief: Thief) {
            x = thief.x
            progress = thief.progress
            lift = thief.kind.lift
        }
    }

    /// A number that floats up where something happened.
    struct Floater: Identifiable {
        let id: Int
        let text: String
        let isLoss: Bool
        let spot: Spot
        var age: Double = 0
    }

    /// Quick burst where a tap landed.
    struct Spark: Identifiable {
        let id: Int
        let spot: Spot
        var age: Double = 0
    }

    /// Big centered callout: a new wave, the boss, a power going off.
    struct Banner: Equatable {
        let id: Int
        let title: String
        let isAlarm: Bool
        var age: Double = 0
    }

    /// Screen-wide flash of a power.
    struct Blast: Equatable {
        let id: Int
        let power: RaidPower
        var age: Double = 0
    }

    static let fadeDuration = 0.35
    static let floaterDuration = 0.9
    static let sparkDuration = 0.28
    static let bannerDuration = 1.6
    static let blastDuration = 0.6

    private static let summonInterval: Double = 5
    private static let summonLimit = 6

    let plan: RaidPlan

    private(set) var phase: Phase = .countdown
    private(set) var countdown: Double
    private(set) var thieves: [Thief] = []
    private(set) var floaters: [Floater] = []
    private(set) var sparks: [Spark] = []
    private(set) var banner: Banner?
    private(set) var blast: Blast?

    /// Monsters in this raid, including ones that join mid-fight.
    private(set) var total: Int
    private(set) var wave = 0
    private(set) var repelled = 0
    private(set) var escaped = 0
    private(set) var bounty: Double = 0
    private(set) var stolen: Double = 0
    /// Kills in a row without letting anyone through.
    private(set) var combo = 0
    private(set) var bestCombo = 0
    /// Goes up by one every time a monster reaches the hoard. Views flash on change.
    private(set) var breachCount = 0
    /// Seconds the monsters stay petrified.
    private(set) var freezeRemaining: Double = 0
    /// Seconds until each power can be used again.
    private(set) var cooldowns: [RaidPower: Double]
    var isPaused = false

    @ObservationIgnored private var bossesDefeated = 0
    @ObservationIgnored private var clock: Double = 0
    @ObservationIgnored private var nextSpawn = 0
    @ObservationIgnored private var lastStep: Date?
    @ObservationIgnored private var serial = 0
    @ObservationIgnored private var nextJoinerID = 10_000
    @ObservationIgnored private var summonClock: Double = 0
    @ObservationIgnored private var summons = 0

    init(plan: RaidPlan) {
        self.plan = plan
        total = plan.spawns.count
        // A new monster or the boss gets a moment longer, so its note can be read.
        countdown = plan.newcomer != nil || plan.hasBoss ? 4.5 : 3
        // Powers start half charged: no opening wipe, but they arrive while the fight is young.
        cooldowns = Dictionary(uniqueKeysWithValues: plan.powers.map { ($0, $0.cooldown * 0.5) })
    }

    var remaining: Int { total - repelled - escaped }
    var isFrozen: Bool { freezeRemaining > 0 }

    var outcome: RaidOutcome {
        RaidOutcome(
            level: plan.level,
            repelled: repelled,
            escaped: escaped,
            bounty: bounty,
            stolen: stolen,
            bestCombo: bestCombo,
            bossesDefeated: bossesDefeated
        )
    }

    func isReady(_ power: RaidPower) -> Bool {
        plan.powers.contains(power) && (cooldowns[power] ?? 0) <= 0
    }

    /// 0 when ready, 1 right after use.
    func cooldownFraction(_ power: RaidPower) -> Double {
        (cooldowns[power] ?? 0) / power.cooldown
    }

    // MARK: Loop

    /// Called every frame with the current time.
    func step(now: Date) {
        let previous = lastStep
        lastStep = now
        guard let previous, !isPaused else { return }

        // Clamp so a hitch never teleports monsters across the cave.
        let delta = min(now.timeIntervalSince(previous), 0.1)
        guard delta > 0 else { return }

        switch phase {
        case .countdown:
            countdown -= delta
            if countdown <= 0 {
                phase = .fighting
            }
        case .fighting:
            advance(by: delta)
        case .finished:
            // Let the last numbers drift away instead of freezing over the result card.
            ageEffects(by: delta)
        }
    }

    // MARK: Player actions

    func hit(_ id: Int) {
        guard phase == .fighting, !isPaused,
              let thief = thieves.first(where: { $0.id == id }),
              !thief.isDefeated, !thief.isPhased else { return }

        // A small shove back makes each tap feel like it landed. The king barely budges.
        let isDown = strike(id, damage: plan.tapDamage, shove: thief.kind.isBoss ? 0.004 : 0.015)
        if isDown {
            Haptics.thud()
        } else {
            Haptics.tap()
        }
    }

    func use(_ power: RaidPower) {
        guard phase == .fighting, !isPaused, isReady(power) else { return }
        cooldowns[power] = power.cooldown
        blast = Blast(id: nextSerial(), power: power)
        banner = Banner(id: nextSerial(), title: power.name, isAlarm: false)

        switch power {
        case .flameBurst:
            let damage = RaidPlanner.flameDamage(tapDamage: plan.tapDamage)
            // Work from a snapshot: a slime that bursts adds slimelings, and those sit this one out.
            for id in thieves.filter({ !$0.isDefeated }).map(\.id) {
                strike(id, damage: damage, shove: 0)
            }
        case .stoneWard:
            freezeRemaining = max(freezeRemaining, RaidPlanner.wardDuration)
        case .tigerRoar:
            for index in thieves.indices where !thieves[index].isDefeated {
                thieves[index].progress = max(0.02, thieves[index].progress - RaidPlanner.roarKnockback)
                thieves[index].flash = 0.12
            }
            freezeRemaining = max(freezeRemaining, RaidPlanner.roarStun)
        }
        Haptics.success()
    }

    /// Give up: every monster still out there gets through.
    func retreat() {
        guard phase != .finished else { return }
        for thief in thieves where !thief.isDefeated {
            stolen += loot(for: thief.kind)
            escaped += 1
        }
        for spawn in plan.spawns[nextSpawn...] {
            stolen += loot(for: spawn.kind)
            escaped += 1
        }
        thieves.removeAll()
        nextSpawn = plan.spawns.count
        combo = 0
        isPaused = false
        phase = .finished
    }

    // MARK: Simulation

    private func advance(by delta: Double) {
        clock += delta

        for power in cooldowns.keys {
            cooldowns[power] = max(0, (cooldowns[power] ?? 0) - delta)
        }

        while nextSpawn < plan.spawns.count, plan.spawns[nextSpawn].time <= clock {
            let spawn = plan.spawns[nextSpawn]
            nextSpawn += 1
            thieves.append(Thief(id: spawn.id, kind: spawn.kind, lane: spawn.lane, maxHP: spawn.hp, hp: spawn.hp))

            if spawn.wave != wave {
                wave = spawn.wave
                announceWave(ledBy: spawn.kind)
            }
        }

        let isFrozen = freezeRemaining > 0
        freezeRemaining = max(0, freezeRemaining - delta)

        var breached = false
        for index in thieves.indices {
            if let age = thieves[index].fadeAge {
                thieves[index].fadeAge = age + delta
                continue
            }

            thieves[index].flash = max(0, thieves[index].flash - delta)
            guard !isFrozen else { continue }

            thieves[index].age += delta
            thieves[index].progress += delta * plan.speedScale / thieves[index].kind.crossingTime

            if thieves[index].progress >= 1 {
                let thief = thieves[index]
                let taken = loot(for: thief.kind)
                stolen += taken
                escaped += 1
                breached = true
                floaters.append(
                    Floater(
                        id: nextSerial(),
                        text: taken >= 1 ? "-\(CoinFormatter.short(taken))" : "Got through",
                        isLoss: true,
                        spot: Spot(thief)
                    )
                )
            }
        }

        if !isFrozen {
            summonReinforcements(after: delta)
        }

        thieves.removeAll { thief in
            thief.progress >= 1 || (thief.fadeAge ?? 0) >= Self.fadeDuration
        }

        ageEffects(by: delta)

        if breached {
            breachCount += 1
            combo = 0
            Haptics.warning()
        }

        if nextSpawn == plan.spawns.count, thieves.isEmpty {
            phase = .finished
            if escaped == 0 {
                Haptics.success()
            }
        }
    }

    /// Takes hit points off a monster. Returns `true` when that finished it.
    @discardableResult
    private func strike(_ id: Int, damage: Int, shove: Double) -> Bool {
        guard let index = thieves.firstIndex(where: { $0.id == id }),
              !thieves[index].isDefeated else { return false }

        thieves[index].hp -= damage
        thieves[index].flash = 0.12
        thieves[index].progress = max(0, thieves[index].progress - shove)

        let thief = thieves[index]
        sparks.append(Spark(id: nextSerial(), spot: Spot(thief)))
        guard thief.hp <= 0 else { return false }

        thieves[index].fadeAge = 0
        repelled += 1
        combo += 1
        bestCombo = max(bestCombo, combo)
        if thief.kind.isBoss {
            bossesDefeated += 1
        }

        let reward = (plan.bountyPerWeight * thief.kind.bountyWeight * RaidPlanner.comboMultiplier(combo)).rounded()
        bounty += reward
        floaters.append(
            Floater(id: nextSerial(), text: "+\(CoinFormatter.short(reward))", isLoss: false, spot: Spot(thief))
        )

        if thief.kind == .slime {
            split(thief)
        }
        return true
    }

    /// A burst slime leaves two slimelings that scatter to either side.
    private func split(_ slime: Thief) {
        let hp = RaidPlanner.hitPoints(for: .slimeling, level: plan.level)
        for offset in [-0.11, 0.11] {
            join(
                Thief(
                    id: nextJoinerID,
                    kind: .slimeling,
                    lane: min(0.9, max(0.1, slime.x + offset)),
                    maxHP: hp,
                    hp: hp,
                    progress: slime.progress
                )
            )
        }
    }

    /// While the Bone King stands, more skeletons keep answering his call.
    private func summonReinforcements(after delta: Double) {
        guard summons < Self.summonLimit,
              thieves.contains(where: { $0.kind.isBoss && !$0.isDefeated }) else { return }

        summonClock += delta
        guard summonClock >= Self.summonInterval else { return }
        summonClock = 0
        summons += 1

        let hp = RaidPlanner.hitPoints(for: .skeleton, level: plan.level)
        join(Thief(id: nextJoinerID, kind: .skeleton, lane: Double.random(in: 0.14...0.86), maxHP: hp, hp: hp))
    }

    private func join(_ thief: Thief) {
        thieves.append(thief)
        nextJoinerID += 1
        total += 1
    }

    private func announceWave(ledBy kind: ThiefKind) {
        let title: String
        if kind.isBoss {
            title = "The Bone King"
        } else if wave == plan.waveCount {
            title = "Final wave"
        } else {
            title = "Wave \(wave)"
        }
        banner = Banner(id: nextSerial(), title: title, isAlarm: kind.isBoss)
        if kind.isBoss {
            Haptics.warning()
        }
    }

    private func ageEffects(by delta: Double) {
        for index in floaters.indices {
            floaters[index].age += delta
        }
        floaters.removeAll { $0.age >= Self.floaterDuration }

        for index in sparks.indices {
            sparks[index].age += delta
        }
        sparks.removeAll { $0.age >= Self.sparkDuration }

        banner?.age += delta
        if let banner, banner.age >= Self.bannerDuration {
            self.banner = nil
        }

        blast?.age += delta
        if let blast, blast.age >= Self.blastDuration {
            self.blast = nil
        }
    }

    private func loot(for kind: ThiefKind) -> Double {
        (plan.lootPerWeight * kind.lootWeight).rounded(.down)
    }

    private func nextSerial() -> Int {
        serial += 1
        return serial
    }
}
