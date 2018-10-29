//
//  TransactionListViewModel.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 12/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import JetLib

protocol TransactionListView: View, AlertPresenter {
    func reloadTransactions()
}

class TransactionListViewModel: ViewModel {

    private let historyRepo: TransactionHistostyRepository

    init(historyRepo: TransactionHistostyRepository) {
        self.historyRepo = historyRepo
    }

    weak var view: TransactionListView?

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

        load(task: historyRepo.fetchTransactions(account: account)).onSuccess { [weak self] in
            self?.transactions = $0
        }.onFail { [weak self] in
            Logger.error($0)
            self?.view?.showAlert(error: $0)
        }

        return super.loadData()
    }
}
