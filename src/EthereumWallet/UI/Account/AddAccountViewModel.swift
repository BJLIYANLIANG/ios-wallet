//
//  AddAccountViewModel.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 22/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import JetLib

class AddAccountViewModel: ViewModel {

    private let repo: AccountRepository

    init(repo: AccountRepository) {
        self.repo = repo
    }

    weak var view: AddAccountController?

    var onAccountAdded: (() -> Void)?

    lazy var createMnemonicCommand: AsyncCommand = AsyncCommand(self, task: { $0.createMnemonic() })
    lazy var importMnemonicCommand: AsyncCommand = AsyncCommand(self, task: { $0.importMnemonic() })
    lazy var createKeyCommand: AsyncCommand = AsyncCommand(self, task: { $0.createKey() })
    lazy var importKeysCommand: AsyncCommand = AsyncCommand(self, task: { $0.importKeys() })

    fileprivate func createKey() -> Task<Account> {
        return submit(task: repo.createNewAccount()).onSuccess{ [weak self] _ in
            self?.onAccountAdded?()
        }.onFail { [weak self] in
            self?.view?.showAlert(title: $0.localizedDescription) // TODO
        }
    }

    fileprivate func importKeys() -> Task<Bool> {
        return view!.showAlert(title: "Not Implemented")
    }

    fileprivate func createMnemonic() -> Task<Bool> {
        return view!.showAlert(title: "Not Implemented")
    }

    fileprivate func importMnemonic() -> Task<Account> {
        return submit(task: view!.resquestMnemonic().chainOnSuccess { [view] (result) in
            view!.requestAccountIndex().map { (mnemonicText: result, accountIndex: $0) }
        }.chainOnSuccess { [repo] (result) in
            return repo.createHDAccount(result.mnemonicText, mnemonicPassphrase: "", keyIndex: result.accountIndex)
        }).onSuccess { [weak self] _ in
            self?.onAccountAdded?()
        }.onFail { [weak self] in
            Logger.error($0)
            self?.view?.showAlert(title: $0.localizedDescription) // TODO
        }
    }
}
