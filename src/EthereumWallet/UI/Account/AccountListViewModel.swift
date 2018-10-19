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
    func selcetedChanged(_ viewModel: AccountListViewModel)
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
            view?.selcetedChanged(self)
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
//
//    func createNewAccount() {
//        submit(task: accountsRepo.createNewAccount()).notify { [weak self] in
//            if $0.isSuccess {
//                let account = $0.result!
//                self?.accounts?.append(account)
//                self?.selected = account
//            } else if !$0.isCancelled {
//                Logger.error($0.error!)
//            }
//        }
//    }
//
//    func addMnemonicAccount() {
//                submit(task: view!.resquestMnemonic().chainOnSuccess { [view] (result) in
//                    view!.requestAccountIndex().map { (mnemonicText: result, accountIndex: $0) }
//                    }.chainOnSuccess { [accountsRepo] (result) in
//                        return accountsRepo.createHDAccount(result.mnemonicText,
//                                                            mnemonicPassphrase: "",
//                                                            keyIndex: result.accountIndex)
//                }).notify { [weak self] in
//                    if $0.isSuccess {
//                        let account = $0.result!
//                        self?.accounts?.append(account)
//                        self?.selected = account
//                    } else if !$0.isCancelled {
//                        Logger.error($0.error!)
//                    }
//                }
//    }
}
