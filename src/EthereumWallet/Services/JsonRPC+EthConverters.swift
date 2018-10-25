//
//  JsonRPC+EthConverters.swift.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 10/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation

extension JsonRPC {

    class Converters {

        static func ether(from string: String?) throws -> Ether {
            guard let string = string else {
                throw Errors.nilValue
            }

            guard string.starts(with: "0x"), let ether = string.ether else {
                throw Errors.incorrectFormat
            }

            return ether
        }

        static func wei(from string: String?) throws -> Wei {
            guard let string = string else {
                throw Errors.nilValue
            }

            guard string.starts(with: "0x") else {
                throw Errors.incorrectFormat
            }

            return string
        }
    }


    enum Errors: Error {
        case nilValue
        case incorrectFormat
    }
}
