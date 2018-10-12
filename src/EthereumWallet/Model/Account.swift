//
//  Account.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 09/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation

typealias AccountAddress = String

struct Account: Codable {

    let address: AccountAddress
}

extension Account {

    func numberTrancatedInMiddle(max symbols: Int = 11) -> String {
        // 0x reducing
        let cleanNumber = address.dropFirst(2)

        // TODO: extract to string extension
        precondition(symbols > 3)

        if symbols >= cleanNumber.count {
            return String(cleanNumber)
        }

        let suffix = (symbols - 1) / 2
        let prefix = symbols - suffix - 1

        return cleanNumber.prefix(prefix) + "\u{2026}" + cleanNumber.suffix(suffix)
    }
}
