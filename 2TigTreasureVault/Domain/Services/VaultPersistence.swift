//
//  VaultPersistence.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import Foundation

/// Reads and writes the vault snapshot.
struct VaultPersistence {
    private let defaults: UserDefaults
    private let key = "vault.save.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> VaultSave? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(VaultSave.self, from: data)
    }

    func store(_ save: VaultSave) {
        guard let data = try? JSONEncoder().encode(save) else { return }
        defaults.set(data, forKey: key)
    }

    func clear() {
        defaults.removeObject(forKey: key)
    }
}
