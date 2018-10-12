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
                          "address":    account.address,
                          "sort":       "ask"]

        //http://api.etherscan.io/api?module=account&action=txlist&address=0xde0b295669a9fd93d5f28d9ec85e40f4cb697bae&startblock=0&endblock=99999999&sort=asc&apikey=YourApiKeyToken

        return try! HttpClient.default.get(Network.current.eherScan, params: parameters)
            .map { (response: JsonResponse<[Transaction]>) in
                return response.data!
            }
    }
}
