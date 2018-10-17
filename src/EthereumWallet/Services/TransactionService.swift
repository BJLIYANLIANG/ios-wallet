//
//  TransactionService.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 15/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import Geth
import JetLib

class TransactionService {

    private let provider: KeystoreAccountProvider
    private let proxy: KeystoreProxy

    init(keystoreProvider: KeystoreAccountProvider, keystoreProxy: KeystoreProxy) {
        self.provider = keystoreProvider
        self.proxy = keystoreProxy
    }

    private var keyStore: GethKeyStore {
        return proxy.keyStore
    }

    func transfer(from: Account, to: AccountAddress, amount: Ether, gasLimit: Int64 = 100, gasPrice: Wei, network: Network, passphrase: String = "") -> Task<Transaction> {
        let task = Task(execute: { () -> GethTransaction in
            let origin = try self.createTransaction(to: to, amount: amount.wei.intValue!, gasLimit: gasLimit, gasPrice: gasPrice.intValue!)
            return try self.signTransaction(origin, by: from.address, network: network, passphrase: passphrase)
        })

        return proxy.syncQueue.async(task).chainOnSuccess(nextTask: {
            self.sendTransaction($0, network: network)
        })
    }

    func minGasPrice(for network: Network) -> Task<Wei> {
        return try! HttpClient.default.post(network.jsonRpc, jsonBody: JsonRPC.Request.gasPrice()).map { (response: JsonResponse<JsonRPC.Response<Wei>>) in
            return try JsonRPC.EthConverters.wei(from: response.data?.result)
        }
    }

    fileprivate func createTransaction(to address: AccountAddress, amount: Int64, gasLimit: Int64, gasPrice: Int64, with data: Data? = nil) throws -> GethTransaction {
var error: NSError?
        let to = GethNewAddressFromHex(address, &error)

        if let err = error {
            throw err
        }

        return GethNewTransaction(1, to, GethBigInt(amount), gasLimit, GethBigInt(gasPrice), data)
    }

    fileprivate func signTransaction(_ transaction: GethTransaction, by accountAddress: AccountAddress, network: Network, passphrase: String = "") throws -> GethTransaction {
        let signer = try keyStore.find(by: accountAddress)
        let chain = GethNewBigInt(network.chainId)
        let signed = try keyStore.signTxPassphrase(signer, passphrase: passphrase, tx: transaction, chainID: chain)
        return signed
    }

    fileprivate func sendTransaction(_ transaction: GethTransaction, network: Network) -> Task<Transaction> {
        return try! HttpClient.default.post(network.jsonRpc, jsonBody: JsonRPC.Request.sendRawTransaction(signed: transaction)).map { resp in
            return Transaction(timeStamp: Date(), hash: "Ads", value: 0.2, direction: .outcome(account: transaction.getTo()!.getHex()) )
        }
    }
}

fileprivate extension JsonRPC.Request {

    static func sendRawTransaction(signed transaction: GethTransaction) throws -> JsonRPC.Request {
        return JsonRPC.Request("eth_sendRawTransaction", content: [try "0x" + Array(transaction.encodeRLP()).hex])
    }

    static func gasPrice() -> JsonRPC.Request {
        return JsonRPC.Request("eth_gasPrice", content: [])
    }
}
