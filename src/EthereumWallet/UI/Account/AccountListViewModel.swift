//
//  AccountListViewModel.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 19/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import JetLib

protocol AccountListView: View {

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
            // TODO store last selection
            selected = accounts?.first
            view?.collectionChanged(self)
        }
    }

    var selected: Account? {
        didSet {
            view?.selectedChanged(self)
        }
    }

    override func loadData() -> NotifyCompletion {
        load(task: accountsRepo.fetchAllAccounts()).notify { [weak self] in
            if $0.isSuccess {
                self?.accounts = $0.result
            } else {
                Logger.error($0.error!)
            }
        }

        return super.loadData()
    }
}
