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

    private let gethQueue = DispatchQueue(label: "geth.keystore", qos: .userInitiated)
    private let provider = GethAccountProvider()

    func getAll() -> Task<[Account]> {
        return gethQueue.async(Task(execute: { try self.provider.all() }))
    }

    func addDeterministicAccount(_ mnemonic: String,
                                 mnemonicPassphrase: String = "",
                                 keyIndex: Int = 0,
                                 accountPassphrase: String = "") -> Task<Account> {
        let hdWallet = DeterministicAccountProvider(mnemonic: mnemonic, passphrase: mnemonicPassphrase)
        return gethQueue.async(Task(execute: {
            try self.provider.importRaw(key: hdWallet.privateKey(at: keyIndex), passphrase: accountPassphrase)
        }))
    }

    func create(passphrase: String) -> Task<Account> {
        return gethQueue.async(Task(execute: { try self.provider.new(passphrase: passphrase) }))
    }
}
