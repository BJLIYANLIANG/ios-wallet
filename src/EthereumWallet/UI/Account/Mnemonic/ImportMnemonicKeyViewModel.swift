//
//  ImportMnemonicKeyViewModel.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 23/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import JetLib

class ImportMnemonicKeyViewModel: ViewModel {

    private let repo: AccountRepository

    init(repo: AccountRepository) {
        self.repo = repo
    }

    lazy var createCommand: AsyncCommand = AsyncCommand(self, task: { $0.importMnemonic() })

    weak var view: ImportMnemonicKeyController?

    var errors: Errors = Errors() {
        didSet {
            view?.display(errors: errors)
        }
    }

    var onSuccess: (() -> Void)?

    var mnemonicParams: MnemonicImportParam = MnemonicImportParam()

    fileprivate func importMnemonic() -> Task<Account> {
        view?.view.endEditing(true)
        return validate(param: mnemonicParams).chainOnSuccess {
            self.repo.createHDAccount($0.mnemonicText!, mnemonicPassphrase: "", keyIndex: $0.keyIndex!)
        }.onSuccess { [repo, onSuccess] in
            repo.selected = $0
            onSuccess?()
        }.onFail { [weak view] in
            view?.showAlert(error: $0)
        }
    }

    fileprivate func validate(param: MnemonicImportParam) -> Task<MnemonicImportParam> {
        guard let text = param.mnemonicText, !text.isEmpty else {
            errors.mnemonicError = "Mnemonic text is empty"
            return Task.cancelled()
        }

        guard let index = param.keyIndex, index >= 0 else {
            errors.indexError = "Wrong wallet number"
            return Task.cancelled()
        }

        return Task(param)
    }

    struct Errors {
        var indexError: String?
        var mnemonicError: String?
    }

    struct MnemonicImportParam {
        var mnemonicText: String?
        var keyIndex: Int?
    }
}
