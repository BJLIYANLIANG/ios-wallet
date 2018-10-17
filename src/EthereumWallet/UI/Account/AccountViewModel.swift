//
//  AccountViewModel.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 08/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import JetLib

protocol AccountSelectionDelegate: class {

    func selectionChanged(_ selectedAccount: Account?)
}

class AccountViewModel: ViewModel<AccountController> {

    let accountsRepo: AccountRepository
    let balancesRepo: AccountBalanceRepository

    init(accountsRepo: AccountRepository, balancesRepo: AccountBalanceRepository) {
        self.accountsRepo = accountsRepo
        self.balancesRepo = balancesRepo
    }

    var accounts: [Account]? {
        didSet {
            // TODO store last selection
            selected = accounts?.first
            view?.accountsCollectionChanged()
        }
    }

    var selected: Account? {
        didSet {
            view?.selcetedAccountChanged()
            delegate?.selectionChanged(selected)
            loadBalance(for: selected)
        }
    }

    var balance: String? {
        didSet {
            view?.accountBalanceChanged()
        }
    }

    weak var delegate: AccountSelectionDelegate? {
        didSet {
            delegate?.selectionChanged(selected)
        }
    }

    override func loadData() -> NotifyCompletion {
        load(task: accountsRepo.fetchAllAccounts()).notify { [weak self] in
            if $0.isSuccess {
                self?.accounts = $0.result
            } else {
                Logger.error($0.error!)
            }
        }.notify { [weak self] (response) in
            if let vm = self, response.result?.isEmpty == true {
                vm.createNewAccount()
            } else {
                let service: TransactionService = container.resolve()
                service.minGasPrice(for: Network.current).onSuccess { gasPrice in
                    service.transfer(from:          response.result!.first!,
                                     to:            response.result!.last!.address,
                                     amount:        0.1,
                                     gasPrice:      gasPrice,
                                     network:       Network.current,
                                     passphrase:    "test passphrase")
                }
            }
        }

        return super.loadData()
    }

    func loadBalance(for account: Account?) {
        balance = nil

        guard let account = account else {
            return
        }

        submit(task: balancesRepo.fetchBalance(for: account), tag: account.address).notify { [weak self] in
            if $0.isSuccess {
                let account = $0.result!.account
                if account.address == self?.selected?.address {
                    self?.balance = $0.result!.balance.description
                }
            } else if $0.isFailed {
                Logger.error($0.error!)
            }
        }
    }

    func createNewAccount() {
        submit(task: accountsRepo.createNewAccount(passphrase: "test passphrase")).notify { [weak self] in
            if $0.isSuccess {
                let account = $0.result!
                self?.accounts?.append(account)
                self?.selected = account
            } else if !$0.isCancelled {
                Logger.error($0.error!)
            }
        }
    }

    func addMnemonicAccount() {
        submit(task: view!.requetMnemonic().chainOnSuccess { [view] (result) in
            view!.reauetAccountIndex().map { (mnemonicText: result, accountIndex: $0) }
        }.chainOnSuccess { [accountsRepo] (result) in
            return accountsRepo.createHDAccount(result.mnemonicText,
                                                mnemonicPassphrase: "",
                                                keyIndex: result.accountIndex,
                                                accountPassphrase: "")
        }).notify { [weak self] in
            if $0.isSuccess {
                let account = $0.result!
                self?.accounts?.append(account)
                self?.selected = account
            } else if !$0.isCancelled {
                Logger.error($0.error!)
            }
        }
    }
}
