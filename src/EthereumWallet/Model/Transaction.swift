//
//  Transaction.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 12/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation

typealias TransactionHash = String

struct Transaction {
    let timeStamp: Date
    let hash: TransactionHash
    let value: Ether
    let direction: Direction

    enum Direction {
        case income(account: AccountAddress)
        case outcome(account: AccountAddress)
    }
}


