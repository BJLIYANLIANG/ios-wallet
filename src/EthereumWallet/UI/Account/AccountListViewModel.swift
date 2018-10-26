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

    func delete(account: Account?) {
        guard let account = account else {
            view?.collectionChanged(self)
            return
        }

        submit(task: accountsRepo.remove(account: account)).onSuccess { [weak self] (_) in
            if account == self?.selected {
                self?.selected = self?.accounts?.filter { $0 != account }.first
            }
            self?.reload(force: true)
        }.onFail { [weak self] in
            guard let vm = self else { return }
            vm.view?.showAlert(error: $0)
            vm.view?.collectionChanged(vm)
        }
    }

    func canDelete(_ account: Account?) -> Bool {
        guard account != nil, let collection = accounts, collection.count > 1 else {
            return false
        }
        return true
    }
}
