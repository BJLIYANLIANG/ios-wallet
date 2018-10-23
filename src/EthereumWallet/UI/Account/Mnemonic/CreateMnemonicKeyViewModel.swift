//
//  CreateMnemonicKeyViewModel.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 23/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import JetLib

class CreateMnemonicKeyViewModel: ViewModel {

    private let repo: AccountRepository

    init(repo: AccountRepository) {
        self.repo = repo
    }

    lazy var createCommand: AsyncCommand = AsyncCommand(self, task: { $0.importMnemonic() })

    weak var view: CreateMnemonicKeyController?

    var errors: Errors = Errors() {
        didSet {
            view?.display(errors: errors)
        }
    }

    var onSuccess: (() -> Void)?

    var mnemonicParams = MnemonicCreateParam()

    fileprivate func importMnemonic() -> Task<Account> {
        view?.view.endEditing(true)
        return validate(param: mnemonicParams).chainOnSuccess {
            self.repo.createHDAccount($0.mnemonicText!, mnemonicPassphrase: "", keyIndex: 0)
        }.onSuccess { [repo, onSuccess] in
            repo.selected = $0
            onSuccess?()
        }.onFail { [weak view] in
            view?.showAlert(title: $0.localizedDescription) // TODO
        }
    }

    fileprivate func validate(param: MnemonicCreateParam) -> Task<MnemonicCreateParam> {
        guard let mnemonic = param.mnemonicText, !mnemonic.isEmpty else {
            errors.mnemonicText = "<TODO> text error"
            return Task.cancelled()
        }

        guard let confirmation = param.confirmationText, !confirmation.isEmpty else {
            errors.mnemonicConfirmation = "<TODO> no confirmation"
            return Task.cancelled()
        }

        guard mnemonic == confirmation else {
            errors.mnemonicConfirmation = "Mnemonic keys does not mach!"
            return Task.cancelled()
        }

        return Task(param)
    }

    struct Errors {
        var mnemonicText: String?
        var mnemonicConfirmation: String?
    }

    struct MnemonicCreateParam {
        var mnemonicText: String?
        var confirmationText: String?
    }
}
