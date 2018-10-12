//
//  GethAccountProvider.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 09/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import Geth

class GethAccountProvider {

    lazy var keyStore: GethKeyStore = {
         let keystorePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/etherium-keys"
        return GethNewKeyStore(keystorePath, GethLightScryptN, GethLightScryptP);
    }()

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
        return try keyStore.exportKey(find(by: account), passphrase: passphrase, newPassphrase: newPassphrase)
    }

    func update(account: Account, passphrase: String, newPassphrase: String) throws {
        try keyStore.update(find(by: account), passphrase: passphrase, newPassphrase: newPassphrase)
    }

    func delete(account: Account, passphrase: String) throws {
        try keyStore.delete(find(by: account), passphrase: passphrase)
    }

    func importRaw(key: Data, passphrase: String) throws -> Account {
        return try keyStore.importECDSAKey(key, passphrase: passphrase).convert()
    }

    func importCrypted(key: Data, passphrase: String, newPassphrase: String) throws -> Account {
        return try keyStore.importKey(key, passphrase: passphrase, newPassphrase: newPassphrase).convert()
    }

    private func find(by account: Account) throws -> GethAccount {
        guard let collection = keyStore.getAccounts() else {
            throw Errors.storageNotFound
        }

        for i in 0..<collection.size() {
            let gaccount = try collection.get(i)

            if gaccount.getAddress()?.getHex() == account.address {
                return gaccount
            }
        }

        throw Errors.accountNotFound
    }

    enum Errors: Error {
        case accountNotFound
        case storageNotFound
    }
}

private extension GethAccount {

    func convert() -> Account {
        return Account(address: self.getAddress()!.getHex())
    }
}

