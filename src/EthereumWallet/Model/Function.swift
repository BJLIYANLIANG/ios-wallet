//
//  Function.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 28/11/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import BigInt


struct Function {

    let name: String
    let input: [Parameter]

    var signature: String {
        return "\(name)(\(input.map({$0.typeName}).joined(separator: ",")))"
    }
}

extension Function {

    enum Parameter {
        case uint8(_ value: UInt8)
        case uint32(_ value: UInt32)
        case uint256(_ value: BigUInt)
        case address(_ value: BigUInt)
        case bool(_ value: Bool)
        case string(_ value: String)
    }
}

extension Function.Parameter {

    var typeName: String {
        switch self {
        case .uint8:     return "uint8"
        case .uint32:    return "uint32"
        case .uint256:   return "uint256"
        case .address:   return "address"
        case .bool:      return "bool"
        case .string:    return "string"
        }
    }
}
