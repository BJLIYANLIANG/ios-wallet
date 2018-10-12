//
//  JsonRPC+EthConverters.swift.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 10/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation

extension JsonRPC {

    class EthConverters {

        static func accountBalance(from string: String?) throws -> Decimal {
            guard let string = string else {
                throw Errors.nilValue
            }

            guard string.starts(with: "0x"), let integer = Int64(string.dropFirst(2), radix: 16) else {
                throw Errors.incorrectFormat
            }

            return Decimal(integer)
        }

        enum Errors: Error {
            case nilValue
            case incorrectFormat
        }
    }
}
