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
    private let loginService: LocalLoginService

    init(keystoreProvider: KeystoreAccountProvider, loginService: LocalLoginService) {
        self.provider = keystoreProvider
        self.loginService = loginService
        self.selected = UserDefaults.standard.value(forKey: LocalStorageKeys.selectedAccount)
    }

    var selected: Account? {
        didSet {
            UserDefaults.standard.set(selected, forKey: LocalStorageKeys.selectedAccount)
            UserDefaults.standard.synchronize()
        }
    }

    func fetchAllAccounts() -> Task<[Account]> {
        return provider.syncQueue.async(Task(execute: { try self.provider.all() }))
    }

    func createHDAccount(_ mnemonic: String,
                         mnemonicPassphrase: String = "",
                         keyIndex: Int = 0) -> Task<Account> {
        let factory = DeterministicAccountFactory(mnemonic: mnemonic, passphrase: mnemonicPassphrase)
        return provider.syncQueue.async(Task(execute: {
            guard let passphrase = try self.loginService.readPincodeFromKeychain() else {
                throw LocalLoginService.Errors.pincodeNotSet
            }
            return try self.provider.importRaw(key: factory.privateKey(at: keyIndex), passphrase: passphrase)
        }))
    }

    func createNewAccount() -> Task<Account> {
        return provider.syncQueue.async(Task(execute: {
            guard let passphrase = try self.loginService.readPincodeFromKeychain() else {
                throw LocalLoginService.Errors.pincodeNotSet
            }
            return try self.provider.new(passphrase: passphrase)
        }))
    }
}
