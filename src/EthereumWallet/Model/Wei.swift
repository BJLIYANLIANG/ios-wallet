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
typealias IntHex = String

private let weiExponent = 18

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
            return decimalFrom(bigHex: String(self.dropFirst(2)))
        } else {
            return Decimal(string: self)
        }
    }
}

extension Wei {

    var ether: Ether? {
        guard let decimal = self.decimal else {
            return nil
        }

        if self.starts(with: "0x") {
            return Ether(sign: .plus, exponent: -weiExponent, significand: decimal)
        } else {
            return Ether(sign: .plus, exponent: -weiExponent, significand: decimal)
        }
    }
}

extension Ether {

    var wei: Wei {
        let wei = Ether(sign: .plus, exponent: weiExponent, significand: self) as NSNumber
        return "0x" + String(wei.int64Value, radix: 16)
    }
}

extension Int64 {

    var hex: IntHex {
        return "0x" + String(self, radix: 16)
    }
}

extension String {

    subscript(_ range: CountableRange<Int>) -> String {
        let idx1 = index(startIndex, offsetBy: max(0, range.lowerBound))
        let idx2 = index(startIndex, offsetBy: min(self.count, range.upperBound))
        return String(self[idx1..<idx2])
    }
}

func decimalFrom(bigHex value: String, groupLenght: Int = 12) -> Decimal? {
    let groups = 1 + value.count / groupLenght
    let exp = pow(16, groupLenght)

    var result: Decimal = 0

    for i in 1...groups {
        let offset = value.count - i * groupLenght
        let from = max(offset, 0)
        let count = min(groupLenght + offset, groupLenght)
        let part = value[from..<from + count]

        guard let int = Int64(part, radix: 16) else {
            return nil
        }

        let decimal = Decimal(int)

        result += decimal * pow(exp, i)
    }

    return result
}
