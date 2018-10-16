//
//  TransactionHistostyRepository.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 12/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import JetLib

class TransactionHistostyRepository {

    func fetchTransactions(account: Account) -> Task<[Transaction]> {
        let parameters = ["module":     "account",
                          "action":     "txlist",
                          "address":    "0xde0b295669a9fd93d5f28d9ec85e40f4cb697bae",//account.address,
                          "sort":       "ask",
                          "endblock":   "99999999",
                          "startblock": "0",
                          "apikey":     Network.etherscanApiKey
        ]

        return try! HttpClient.default.get(Network.current.eherscan, params: parameters)
            .map { (response: JsonResponse<Wrapper<[EtherscanTransaction]>>) in
                return response.data?.result.map { $0.convert(myAccount: account) } ?? []
            }
    }

    fileprivate struct Wrapper<T: Codable>: Codable {
        var status: String
        var message: String
        var result: T
    }

    fileprivate struct EtherscanTransaction: Codable {

        let blockNumber: String
        let timeStamp: String
        let hash: String
        let blockHash: String

        let nonce: String
        let transactionIndex: String

        let from: AccountAddress
        let to: AccountAddress

        let value: String
        let gas: String
        let gasPrice: String

        let isError: String
        let txreceipt_status: String
        let input: String

        let contractAddress: String
        let cumulativeGasUsed: String
        let confirmations: String

        func convert(myAccount: Account) -> Transaction {
            return Transaction(timeStamp: Date(timeIntervalSince1970: TimeInterval(timeStamp) ?? 0),
                               hash: hash,
                               value: value.ether!,
                               direction: myAccount.address == from ? .outcome(account: to) : .income(account: from))
        }
    }
}
