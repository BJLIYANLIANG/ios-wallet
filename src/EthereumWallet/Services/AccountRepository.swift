//
//  AccountRepository.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 09/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import JetLib

class AccountRepository {

    private let provider: KeystoreAccountProvider

    init(keystoreProvider: KeystoreAccountProvider) {
        self.provider = keystoreProvider
    }

    func fetchAllAccounts() -> Task<[Account]> {
        return provider.syncQueue.async(Task(execute: { try self.provider.all() }))
    }

    func createHDAccount(_ mnemonic: String,
                         mnemonicPassphrase: String = "",
                         keyIndex: Int = 0,
                         accountPassphrase: String = "") -> Task<Account> {
        let factory = DeterministicAccountFactory(mnemonic: mnemonic, passphrase: mnemonicPassphrase)
        return provider.syncQueue.async(Task(execute: {
            try self.provider.importRaw(key: factory.privateKey(at: keyIndex), passphrase: accountPassphrase)
        }))
    }

    func createNewAccount(passphrase: String) -> Task<Account> {
        return provider.syncQueue.async(Task(execute: { try self.provider.new(passphrase: passphrase) }))
    }
}
