//
//  Wei.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 15/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation

typealias Wei = String
typealias Ether = Decimal

private let weiExponent = 18

extension Wei {

    var ether: Ether? {
        if let int = intValue {
            return Ether(sign: .plus, exponent: -weiExponent, significand: Decimal(int))
        } else {
            return nil
        }
    }

    var intValue: Int64? {
        if self.starts(with: "0x") {
            return Int64(self.dropFirst(2), radix: 16)
        } else {
            return Int64(self, radix: 10)
        }
    }
}

extension Ether {

    var wei: Wei {
        let wei = Ether(sign: .plus, exponent: weiExponent, significand: self) as NSNumber
        return "0x" + String(wei.int64Value, radix: 16)
    }
}
