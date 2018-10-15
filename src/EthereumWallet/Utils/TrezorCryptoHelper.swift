//
//  TrezorCryptoHelper.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 11/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import TrezorCrypto

fileprivate var ecdsa_curve = secp256k1

class TrezorCrypto {

    static func seedFromMnemonic(_ mnemonic: String, passphrase: String = "") -> [UInt8] {
        var seed = [UInt8](repeating: 0, count: 64)
        mnemonic_to_seed(mnemonic, passphrase, &seed, nil)
        return seed
    }

    static func etheriumPrivateKey(at path: [UInt32], with seed: [UInt8]) -> [UInt8] {
        var node = HDNode()

        hdnode_from_seed(seed, Int32(seed.count), "secp256k1", &node)

        for index in path {
            hdnode_private_ckd(&node, index)
        }

        return Array(Data(withUnsafeBytes(of: &node.private_key) { $0 }))
    }

    static func publicKeyFrom(privateKey: [UInt8], compressed: Bool = true) -> [UInt8] {
        if compressed {
            var key = [UInt8](repeating: 0, count: 33)
            ecdsa_get_public_key33(&ecdsa_curve, privateKey, &key)
            return key
        } else {
            var key = [UInt8](repeating: 0, count: 65)
            ecdsa_get_public_key65(&ecdsa_curve, privateKey, &key);
            return key
        }
    }

    static func etheriumAddress(privateKey: [UInt8]) -> [UInt8] {
        let publicKey = Array(publicKeyFrom(privateKey: privateKey, compressed: false)[1...64])
        var address = [UInt8](repeating: 0, count: Int(sha3_256_hash_size))
        keccak_256(publicKey, publicKey.count, &address)
        return Array(address[12...31])
    }
}
