//
//  Haptics.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import Foundation
import UIKit

/// Thin wrapper so features never touch feedback generators directly.
enum Haptics {
    private static var isEnabled: Bool {
        UserDefaults.standard.object(forKey: AppSettings.hapticsKey) as? Bool ?? true
    }

    static func tap() {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func thud() {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func success() {
        guard isEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func warning() {
        guard isEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}
