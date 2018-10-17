//
//  KeystoreProxy.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 15/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import Geth

class KeystoreProxy {

    lazy var keyStore: GethKeyStore = {
        let keystorePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/etherium-keys"
        return GethNewKeyStore(keystorePath, GethLightScryptN, GethLightScryptP);
    }()

    let syncQueue: DispatchQueue = DispatchQueue(label: "geth.keystore.queue", qos: .userInitiated)

}

extension GethKeyStore {

    func find(by adress: AccountAddress) throws -> GethAccount {
        guard let collection = self.getAccounts() else {
            throw Errors.storageNotFound
        }

        for i in 0..<collection.size() {
            let gaccount = try collection.get(i)

            if gaccount.getAddress()?.getHex() == adress {
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
