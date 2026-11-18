//
//  AppLink.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import Foundation

/// Every external address the app opens, kept in one place.
enum AppLink: String {
    case privacyPolicy = "https://www.termsfeed.com/live/1b8745c1-36d8-4015-80e2-6381f515611d"
    case termsOfUse = "https://www.termsfeed.com/live/a0ac30d7-c763-4d02-93ab-dface8a026e2"

    var url: URL? {
        URL(string: rawValue)
    }
}
