//
//  FunctionSelectorEncoder.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 28/11/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import BigInt

extension Function.Parameter {

    var encoded: [UInt8] {
        switch self {
        case .uint8(let value): return encode(uint8: value)
        case .uint32(let value): return encode(uint32: value)
        case .uint256(let value): return encode(uint256: value)
        case .address(let value): return encode(uint160: value)
        case .bool(let value): return encode(bool: value)
        case .string(let value): return encode(string: value)
        }
    }
}

extension Function {

    var encodedSignature: [UInt8] {
        return [UInt8](TrezorCrypto.keccak256(string: self.signature)[0..<4])
    }

    var encodedSelector: [UInt8] {
        return input.reduce(encodedSignature, { $0 + $1.encoded })
    }
}

private let wordLenght = 256 / 8

private func encode(uint8: UInt8) -> [UInt8] {
    return encode(BigUInt(uint8))
}

private func encode(uint32: UInt32) -> [UInt8] {
    return encode(BigUInt(uint32))
}

private func encode(uint256: BigUInt) -> [UInt8] {
    return encode(uint256)
}

private func encode(uint160: BigUInt) -> [UInt8] {
    return encode(uint160)
}

private func encode(bool: Bool) -> [UInt8] {
    return encode(uint8: bool ? 1 : 0)
}

private func encode(string: String) -> [UInt8] {
    var data = string.data(using: .utf8)!
    let count = data.count

    if data.count % wordLenght != 0 {
        data.append(Data(count: wordLenght - data.count % wordLenght))
    }

    return encode(uint32: UInt32(exactly: count)!) + [UInt8](data)
}

private func encode(_ buint: BigUInt) -> [UInt8] {
    let serialized = buint.serialize()
    var result = Data(count: wordLenght - serialized.count)
    result.append(serialized)
    return [UInt8](result)
}
