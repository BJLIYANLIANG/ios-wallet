//
//  AccountBalanceRepository.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 09/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import JetLib

typealias AccountBalance = (account: Account, balance: Ether)

class AccountBalanceRepository {

    func fetchBalance(for account: Account) -> Task<AccountBalance> {
        return try! HttpClient.default.post(Network.current.jsonRpc, jsonBody: JsonRPC.Request.balance(for: account))
            .map { (response: JsonResponse<JsonRPC.Response<String>>) in
                return try AccountBalance(account: account, balance: JsonRPC.EthConverters.ether(from: response.data?.result))
            }
    }
}

extension JsonRPC.Request {

    static func balance(for account: Account) -> JsonRPC.Request {
        return JsonRPC.Request("eth_getBalance", content: [account.address, "latest"])
    }
}
