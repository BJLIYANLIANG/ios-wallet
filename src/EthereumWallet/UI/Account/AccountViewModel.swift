//
//  AccountViewModel.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 08/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import JetLib

protocol AccountView: View, AlertPresenter {

    func balanceChanged(_ viewModel: AccountViewModel)
    func accountChanged(_ viewModel: AccountViewModel)
}

class AccountViewModel: ViewModel {

    let accountsRepo: AccountRepository
    let balancesRepo: AccountBalanceRepository

    init(accountsRepo: AccountRepository, balancesRepo: AccountBalanceRepository) {
        self.accountsRepo = accountsRepo
        self.balancesRepo = balancesRepo

        self.account = accountsRepo.selected
    }

    weak var view: AccountView?

    lazy var copyAddressCommand = ActionCommand(self) {
        UIPasteboard.general.string = $0.account?.address
    }

    var account: Account? {
        didSet {
            if oldValue?.address != account?.address {
                reloadBalance()
            }
            view?.accountChanged(self)
        }
    }

    var balance: Ether? {
        didSet {
            view?.balanceChanged(self)
        }
    }

    override func loadData() -> NotifyCompletion {
        view?.accountChanged(self)
        reloadBalance()
        return super.loadData()
    }

    private func reloadBalance() {
        guard let account = account else {
            return
        }

        load(task: balancesRepo.fetchBalance(for: account), tag: account.address).onSuccess { [weak self] in
            if $0.account.address == self?.account?.address {
                self?.balance = $0.balance
            }
        }.onFail { [weak self] in
            Logger.error($0)
            self?.view?.showAlert(error: $0)
        }
    }
}

extension AccountViewModel: SelectedAccountDelegate {

    func accountChanged(_ account: Account?) {
        self.account = account
    }
}
