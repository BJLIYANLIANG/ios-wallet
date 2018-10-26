//
//  AccountListViewModel.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 19/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import JetLib

protocol AccountListView: View, AlertPresenter {

    func collectionChanged(_ viewModel: AccountListViewModel)
    func selectedChanged(_ viewModel: AccountListViewModel)
}

class AccountListViewModel: ViewModel {

    let accountsRepo: AccountRepository

    init(accountsRepo: AccountRepository) {
        self.accountsRepo = accountsRepo
    }

    weak var view: AccountListView?

    var accounts: [Account]? {
        didSet {
            selected = accounts?.first(where: { $0.address == selected?.address })
            view?.collectionChanged(self)
        }
    }

    var selected: Account? {
        didSet {
            if storeSelection {
                accountsRepo.selected = selected
            }

            view?.selectedChanged(self)
        }
    }

    var storeSelection: Bool = true

    override func loadData() -> NotifyCompletion {
        selected = accountsRepo.selected

        load(task: accountsRepo.fetchAllAccounts()).onSuccess { [weak self] in
            self?.accounts = $0
        }.onFail { [weak self] in
            Logger.error($0)
            self?.view?.showAlert(error: $0)
        }

        return super.loadData()
    }
}
