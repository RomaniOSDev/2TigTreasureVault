//
//  AppSettings.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import Foundation
import Observation

/// Player preferences that live outside the vault save.
@Observable
final class AppSettings {
    static let hapticsKey = "settings.hapticsEnabled"
    static let onboardingKey = "settings.hasSeenOnboarding"

    var hapticsEnabled: Bool {
        didSet { defaults.set(hapticsEnabled, forKey: Self.hapticsKey) }
    }

    var hasSeenOnboarding: Bool {
        didSet { defaults.set(hasSeenOnboarding, forKey: Self.onboardingKey) }
    }

    @ObservationIgnored private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        hapticsEnabled = defaults.object(forKey: Self.hapticsKey) as? Bool ?? true
        hasSeenOnboarding = defaults.bool(forKey: Self.onboardingKey)
    }
}
