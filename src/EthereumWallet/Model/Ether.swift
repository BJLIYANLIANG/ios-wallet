//
//  Wei.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 15/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import BigInt

typealias Wei = String
typealias IntHex = String

private let weiExponent = 18

struct Ether {

    init(wei: Wei) {
        self.wei = wei
    }

    init?(etherDecimalString: String) {
        guard let decimal = Decimal(string: etherDecimalString) else {
            return nil
        }

        guard let mag = BigInt(Ether.removeNotDigeits(from: etherDecimalString), radix: 10) else {
            return nil
        }
        let exp = BigInt(10).power(decimal.exponent + weiExponent)

        wei = "0x" + String(exp * mag, radix: 16)
    }

    let wei: Wei

    var decimal: Decimal? {
        guard let dec = wei.decimal else {
            return nil
        }
        
        return Decimal(sign: .plus, exponent: -weiExponent, significand: dec)
    }

    fileprivate static func removeNotDigeits(from string: String) -> String {
        return string
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: " ", with: "")
    }
}

extension IntHex {

    var intValue: Int64? {
        if self.starts(with: "0x") {
            return Int64(self.dropFirst(2), radix: 16)
        } else {
            return Int64(self, radix: 10)
        }
    }

    var decimal: Decimal? {
        if self.starts(with: "0x") {
            guard let bint = BigInt(self.dropFirst(2), radix: 16) else {
                return nil
            }
            return Decimal(string: String(bint, radix: 10))
        } else {
            return Decimal(string: self)
        }
    }
}

extension Ether: CustomStringConvertible {

    var description: String {
        return decimal?.description ?? " - "
    }
}

extension Wei {

    var ether: Ether? {
        return Ether(wei: self)
    }
}

extension Int64 {

    var hex: IntHex {
        return "0x" + String(self, radix: 16)
    }
}
