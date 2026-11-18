//
//  VaultSlot.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import Foundation

/// An item standing on a pedestal.
struct PlacedItem: Codable, Equatable {
    var kind: VaultItemKind
    var level: Int
    /// Everything spent on this item so far. Half of it comes back on removal.
    var invested: Double
}

/// One pedestal in the cave.
struct VaultSlot: Codable, Equatable {
    var isUnlocked: Bool
    var item: PlacedItem?
}
