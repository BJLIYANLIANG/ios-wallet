//
//  KeystoreAccountProvider.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 09/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import Geth

class KeystoreAccountProvider {

    private let proxy: KeystoreProxy

    init(keyStoreProxy: KeystoreProxy) {
        self.proxy = keyStoreProxy
    }

    var keyStore: GethKeyStore {
        return proxy.keyStore
    }

    var syncQueue: DispatchQueue {
        return proxy.syncQueue
    }

    func all() throws -> [Account] {
        guard let collection = keyStore.getAccounts() else {
            return []
        }

        var result = [Account]()

        for i in 0..<collection.size() {
            result.append(try collection.get(i).convert())
        }

        return result
    }

    func new(passphrase: String) throws -> Account {
        return try keyStore.newAccount(passphrase).convert()
    }

    func export(account: Account, passphrase: String, newPassphrase: String) throws -> Data {
        return try keyStore.exportKey(keyStore.find(by: account.address), passphrase: passphrase, newPassphrase: newPassphrase)
    }

    func update(account: Account, passphrase: String, newPassphrase: String) throws {
        try keyStore.update(keyStore.find(by: account.address), passphrase: passphrase, newPassphrase: newPassphrase)
    }

    func delete(account: Account, passphrase: String) throws {
        try keyStore.delete(keyStore.find(by: account.address), passphrase: passphrase)
    }

    func importRaw(key: Data, passphrase: String) throws -> Account {
        return try keyStore.importECDSAKey(key, passphrase: passphrase).convert()
    }

    func importCrypted(key: Data, passphrase: String, newPassphrase: String) throws -> Account {
        return try keyStore.importKey(key, passphrase: passphrase, newPassphrase: newPassphrase).convert()
    }
}

private extension GethAccount {

    func convert() -> Account {
        return Account(address: self.getAddress()!.getHex()!.lowercased())
    }
}
