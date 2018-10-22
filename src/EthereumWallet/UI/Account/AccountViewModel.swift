//
//  AccountViewModel.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 08/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import JetLib

protocol AccountView: View {

    func balanceChanged(_ viewModel: AccountViewModel)
    func accountChanged(_ viewModel: AccountViewModel)
}

class AccountViewModel: ViewModel {

    let accountsRepo: AccountRepository
    let balancesRepo: AccountBalanceRepository

    init(accountsRepo: AccountRepository, balancesRepo: AccountBalanceRepository) {
        self.accountsRepo = accountsRepo
        self.balancesRepo = balancesRepo
    }

    weak var view: AccountView?

    var account: Account? {
        didSet {
            view?.accountChanged(self)
            balance = nil
            reload(force: true)
        }
    }

    var balance: Ether? {
        didSet {
            view?.balanceChanged(self)
        }
    }

    override func loadData() -> NotifyCompletion {
        reloadBalance()
        return super.loadData()
    }

    private func reloadBalance() {
        guard let account = account else {
            return
        }

        load(task: balancesRepo.fetchBalance(for: account), tag: account.address).notify { [weak self] in
            if $0.isSuccess {
                let account = $0.result!.account
                if account.address == self?.account?.address {
                    self?.balance = $0.result!.balance
                }
            } else if $0.isFailed {
                Logger.error($0.error!)
            }
        }
    }
}
