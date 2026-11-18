//
//  CoinFormatter.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import Foundation

enum CoinFormatter {
    private static let suffixes = ["K", "M", "B", "T", "Qa"]

    /// 950 -> "950", 1 234 -> "1.23K", 45 600 000 -> "45.6M".
    /// Always truncates, so the label never promises more than the player has.
    static func short(_ value: Double) -> String {
        let amount = max(0, value)
        guard amount >= 1_000 else {
            return String(Int(amount.rounded(.down)))
        }

        var scaled = amount / 1_000
        var index = 0
        while scaled >= 1_000, index < suffixes.count - 1 {
            scaled /= 1_000
            index += 1
        }

        let digits = scaled < 10 ? 2 : (scaled < 100 ? 1 : 0)
        let factor = pow(10, Double(digits))
        let truncated = (scaled * factor).rounded(.down) / factor
        return String(format: "%.\(digits)f", truncated) + suffixes[index]
    }

    /// Per-second amounts keep one decimal while they are small.
    static func rate(_ value: Double) -> String {
        let amount = max(0, value)
        guard amount < 100 else { return short(amount) }
        let truncated = (amount * 10).rounded(.down) / 10
        if truncated == truncated.rounded() {
            return String(Int(truncated))
        }
        return String(format: "%.1f", truncated)
    }

    /// 45 -> "45s", 300 -> "5m", 8 040 -> "2h 14m".
    static func duration(_ seconds: Double) -> String {
        let total = Int(max(0, seconds))
        let hours = total / 3_600
        let minutes = (total % 3_600) / 60
        if hours > 0 {
            return minutes > 0 ? "\(hours)h \(minutes)m" : "\(hours)h"
        }
        if minutes > 0 {
            return "\(minutes)m"
        }
        return "\(total)s"
    }
}
