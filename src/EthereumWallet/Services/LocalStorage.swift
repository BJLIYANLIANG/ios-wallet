//
//  LocalStorage.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 23/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation

enum LocalStorageKeys: String {

    case useBiomericLogin
    case pincodeInited
    case selectedAccount
    case selectedNetwork
}

extension UserDefaults {

    func value<T: Codable>(forKey defaultName: LocalStorageKeys) -> T? {
        guard let data = self.data(forKey: defaultName.rawValue) else {
            return nil
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            Logger.error(error)
            return nil
        }
    }

    func set<T: Codable>(_ value: T, forKey defaultName: LocalStorageKeys) {
        do {
            let data = try JSONEncoder().encode(value)
            self.set(data, forKey: defaultName.rawValue)
        } catch {
            Logger.error(error)
        }
    }
}
