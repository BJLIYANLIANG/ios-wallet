//
//  TransactionListViewModel.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 12/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import JetLib

class TransactionListViewModel: ViewModel<TransactionListController> {

    private let historyRepo: TransactionHistostyRepository

    init(historyRepo: TransactionHistostyRepository) {
        self.historyRepo = historyRepo
    }

    var account: Account? {
        didSet {
            guard account?.address != oldValue?.address else {
                return
            }

            self.reload(force: true)
        }
    }

    var transactions: [Transaction]? {
        didSet {
            view?.reloadTransactions()
        }
    }

    override func loadData() -> NotifyCompletion {
        guard let account = account else {
            transactions = nil
            return super.loadData()
        }

        load(task: historyRepo.fetchTransactions(account: account)).notify { [weak self] in
            if $0.isSuccess {
                self?.transactions = $0.result
            } else {
                // TODO: display error
            }
        }

        return super.loadData()
    }
}
