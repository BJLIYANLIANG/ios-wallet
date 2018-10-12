//
//  Transaction.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 12/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation

struct Transaction: Codable {

    let blockNumber: Int64
    let timeStamp: Int64
    let hash: String
    let blockHash: String

    let nonce: Int64
    let transactionIndex: Int64

    let from: AccountAddress
    let to: AccountAddress

    let value: String
    let gas: Int64
    let gasPrice: Int64

    let isError: UInt8
    let txreceipt_status: String
    let input: String

    let contractAddress: String
    let cumulativeGasUsed: Int64
    let confirmations: Int64
}

