//
//  VaultItemKind.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import Foundation

/// Everything the keeper can place on a pedestal.
enum VaultItemKind: String, Codable, CaseIterable, Identifiable {
    case woodenChest
    case torch
    case coinPile
    case brazier
    case goldChest
    case guardianStatue
    case gemCluster
    case tigerStatue
    case crownPedestal

    var id: String { rawValue }
}
