//
//  DeterministicAccountProvider.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 10/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import CryptoSwift

class DeterministicAccountProvider {

    private let seed: [UInt8]

    init(mnemonic: String, passphrase: String = "") {
        self.seed = TrezorCrypto.seedFromMnemonic(mnemonic, passphrase: passphrase)
    }

    func privateKey(at index: Int) -> Data {
        let path: [UInt32] = CryptoAccountPath("m/44'/60'/0'/0/\(index)")!.path
        return Data(TrezorCrypto.etheriumPrivateKey(at: path, with: seed))
    }

    func account(at index: Int) -> (address: String, privateKey: Data, publicKey: Data) {
        let path: [UInt32] = CryptoAccountPath("m/44'/60'/0'/0/\(index)")!.path
        let privateKey = TrezorCrypto.etheriumPrivateKey(at: path, with: seed)
        let address = TrezorCrypto.etheriumAddress2(privateKey: privateKey)
        let publicKey = TrezorCrypto.publicKeyFrom(privateKey: privateKey)

        return (address: address.toHexString(), privateKey: Data(privateKey), publicKey: Data(publicKey))
    }

    struct CryptoAccountPath {

        let path: [UInt32]

        public init?(_ string: String) {
            var path = [UInt32]()

            for part in string.split(separator: "/") where part != "m" {
                guard let index = Int(part.replacingOccurrences(of: "'", with: "")) else {
                    return nil
                }

                path.append(CryptoAccountPath.pathComponent(index: index, hardened: part.hasSuffix("'")))
            }

            guard path.count == 5 else {
                return nil
            }

            self.path = path
        }

        static func pathComponent(index: Int, hardened: Bool) -> UInt32 {
            return hardened ? UInt32(index) | 0x80000000 : UInt32(index)
        }
    }
}
