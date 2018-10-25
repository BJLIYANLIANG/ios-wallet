//
//  SentTransactionViewModel.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 24/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import JetLib

class SendTransactionViewModel: ViewModel {

    private let service: TransactionService

    init(service: TransactionService) {
        self.service = service
    }

    weak var view: SendTransactionController?

    var from: Account? {
        didSet {
            view?.fromChanged(self)
        }
    }

    var to: AccountAddress? {
        didSet {
            view?.toChanged(self)
        }
    }

    var amountString: String? {
        didSet {
            view?.amountChanged(self)
        }
    }

    var amount: Ether? {
        guard let str = amountString else {
            return nil
        }
        return Ether(string: str)
    }

    lazy var sendTransactionCommand = AsyncCommand(self, task: { $0.send() }, canExecute: { !$0.loading })

    fileprivate func send() -> Task<TransactionHash> {
        return submit(task: validate().chainOnSuccess { [service] in
            service.transfer(from: $0.from, to: $0.to, amount: $0.amount, network: Network.current)
        }).onSuccess { [weak self] in
            self?.view?.showAlert(title: "<TODO> Success", message: "<TODO> hash: \($0)")
        }.onFail { [weak self] in
            self?.view?.showError($0)
        }
    }

    fileprivate func validate() -> Task<TransactionParams> {
        guard let from = from else { return Task(Errors.noFrom) }
        guard let to = to else { return Task(Errors.noTo) }
        guard let amount = amount else { return Task(Errors.wrongAmount) }

        return Task(TransactionParams(amount: amount, from: from, to: to))
    }

    struct TransactionParams {
        let amount: Ether
        let from: Account
        let to: AccountAddress
    }

    enum Errors: String, Error {
        case noFrom = "<TODO> select from"
        case noTo = "<TODO> select to"
        case wrongAmount = "<TODO> wrong amount"
    }
}
