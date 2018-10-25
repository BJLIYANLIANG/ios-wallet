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
    private let loginService: LocalLoginService

    init(keystoreProvider: KeystoreAccountProvider, keystoreProxy: KeystoreProxy, loginService: LocalLoginService) {
        self.provider = keystoreProvider
        self.proxy = keystoreProxy
        self.loginService = loginService
    }

    private var keyStore: GethKeyStore {
        return proxy.keyStore
    }

    func transfer(from: Account, to: AccountAddress, amount: Ether, network: Network) -> Task<TransactionHash> {
        let passphrase = try! self.loginService.readPincodeFromKeychain()
        return minGasPrice(for: network).chainOnSuccess { gasPrice in
            try self.estimatedGas(for: network, from: from, to: to, gasPrice: gasPrice, value: amount).map { return (gasPrice: gasPrice, estGas: $0) }
        }.chainOnSuccess { gas in
            self.transfer(from: from, to: to, amount: amount, gasLimit: gas.estGas, gasPrice: gas.gasPrice, network: network, passphrase: passphrase ?? "")
        }
    }

    func transfer(from: Account, to: AccountAddress, amount: Ether, gasLimit: Int64, gasPrice: Wei, network: Network, passphrase: String = "") -> Task<TransactionHash> {
        return transactionCount(account: from, in: network).chainOnSuccess { count in
            self.proxy.syncQueue.async(Task(execute: {
                let origin = try self.createTransaction(to: to, nonce: count, amount: amount.wei.intValue!, gasLimit: gasLimit, gasPrice: gasPrice.intValue!)
                return try self.signTransaction(origin, by: from.address, network: network, passphrase: passphrase)
            }))
        }.chainOnSuccess {
            self.sendTransaction($0, network: network)
        }
    }

    func minGasPrice(for network: Network) -> Task<Wei> {
        return try! HttpClient.default.post(network.jsonRpc, jsonBody: JsonRPC.Request.gasPrice()).map { (response: JsonResponse<JsonRPC.Response<Wei>>) in
            Logger.debug(String(data: response.content))
            return try JsonRPC.Converters.wei(from: response.data?.result)
        }
    }

    func estimatedGas(for network: Network, from: Account, to: AccountAddress, gasPrice: Wei, value: Ether) throws -> Task<Int64> {
        let requestBody = try JsonRPC.Request.estimateGasForSend(from: from, to: to, gasPrice: gasPrice, value: value)
        return try HttpClient.default.post(network.jsonRpc, jsonBody: requestBody).map { (r: JsonResponse<JsonRPC.Response<IntHex>>) in
            Logger.debug(String(data: r.content))
            guard let int = r.data?.result.intValue else {
                throw JsonRPC.Errors.nilValue
            }

            return int
        }
    }

    func transactionCount(account: Account, in network: Network) -> Task<Int64> {
        return try! HttpClient.default.post(network.jsonRpc, jsonBody: JsonRPC.Request.getTransactionCount(for: account)).map { (r: JsonResponse<JsonRPC.Response<IntHex>>) in
            Logger.debug(String(data: r.content))
            guard let int = r.data?.result.intValue else {
                throw JsonRPC.Errors.nilValue
            }

            return int
        }
    }

    fileprivate func createTransaction(to address: AccountAddress, nonce: Int64, amount: Int64, gasLimit: Int64, gasPrice: Int64, with data: Data? = nil) throws -> GethTransaction {
var error: NSError?
        let to = GethNewAddressFromHex(address, &error)

        if let err = error {
            throw err
        }

        return GethNewTransaction(nonce, to, GethBigInt(amount), gasLimit, GethBigInt(gasPrice), data)
    }

    fileprivate func signTransaction(_ transaction: GethTransaction, by accountAddress: AccountAddress, network: Network, passphrase: String = "") throws -> GethTransaction {
        let signer = try keyStore.find(by: accountAddress)
        let chain = GethNewBigInt(network.chainId)
        let signed = try keyStore.signTxPassphrase(signer, passphrase: passphrase, tx: transaction, chainID: chain)

        return signed
    }

    fileprivate func sendTransaction(_ transaction: GethTransaction, network: Network) -> Task<TransactionHash> {
        return try! HttpClient.default.post(network.jsonRpc, jsonBody: JsonRPC.Request.sendRawTransaction(signed: transaction))
            .map { (response: JsonResponse<JsonRPC.Response<TransactionHash>>) in
                Logger.debug(String(data: response.content))
                guard let hash = response.data?.result else {
                    throw JsonRPC.Errors.nilValue
                }
                return hash
            }
    }
}

fileprivate extension JsonRPC.Request {

    static func sendRawTransaction(signed transaction: GethTransaction) throws -> JsonRPC.Request {
        return JsonRPC.Request("eth_sendRawTransaction", content: [try "0x" + Array(transaction.encodeRLP()).hex])
    }

    static func estimateGasForSend(from: Account, to: AccountAddress, gasPrice: Wei, value: Ether) throws -> JsonRPC.GenericRequest<[EstimateGasRequetsBody]> {
        let body = EstimateGasRequetsBody(from: from.address,
                               to: to,
                               gas: "0x5208",
                               value: value.wei)
        return JsonRPC.GenericRequest("eth_estimateGas", content: [body])
    }

    static func getTransactionCount(for account: Account) -> JsonRPC.Request {
        return JsonRPC.Request("eth_getTransactionCount", content: [account.address, "latest"])
    }

    static func gasPrice() -> JsonRPC.Request {
        return JsonRPC.Request("eth_gasPrice", content: [])
    }

    struct EstimateGasRequetsBody: Codable {
        let from: AccountAddress
        let to: AccountAddress
        let gas: IntHex
        let value: Wei
    }
}
