//
//  AddAccountController.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 22/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import UIKit
import JetLib

class AddAccountController: UIViewController {

    lazy var viewModel: AddAccountViewModel = container.resolve()

    @IBOutlet weak var mnemonicCreate: UIButton!
    @IBOutlet weak var mnemonicImport: UIButton!
    @IBOutlet weak var regularCreate: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.view = self
        add(viewModel)

        mnemonicCreate.command = viewModel.mnemonicCreateCommand
        mnemonicImport.command = viewModel.mnemonicImportCommand
        regularCreate.command = viewModel.createKeyCommand
    }
}

class AddAccountViewModel: ViewModel {

    private let repo: AccountRepository

    init(repo: AccountRepository) {
        self.repo = repo
    }

    weak var view: AddAccountController?

    var onAccountAdded: (() -> Void)?

    lazy var createKeyCommand = AsyncCommand(self, task: { $0.createKey() })
    lazy var importKeysCommand = AsyncCommand(self, task: { $0.importKeys() })
    lazy var mnemonicImportCommand = ActionCommand.pushScreen(self.view!, sbName: "Account", controllerId: "importMnemonic", configure: onKeyImported)
    lazy var mnemonicCreateCommand = ActionCommand.pushScreen(self.view!, sbName: "Account", controllerId: "createMnemonic", configure: onKeyCreated)

    fileprivate func createKey() -> Task<Account> {
        return submit(task: repo.createNewAccount()).onSuccess{ [weak self] in
            self?.repo.selected = $0
            self?.onAccountAdded?()
        }.onFail { [weak self] in
            self?.view?.showAlert(title: $0.localizedDescription) // TODO
        }
    }

    fileprivate func importKeys() -> Task<Bool> {
        return view!.showAlert(title: "Not Implemented")
    }

    fileprivate func onKeyImported(ctrl: ImportMnemonicKeyController) {
        ctrl.viewModel.onSuccess = { [weak self] in
            self?.onAccountAdded?()
            ctrl.navigationController?.popViewController(animated: true)
        }
    }

    fileprivate func onKeyCreated(ctrl: CreateMnemonicKeyController) {
        ctrl.viewModel.onSuccess = { [weak self] in
            self?.onAccountAdded?()
            ctrl.navigationController?.popViewController(animated: true)
        }
    }
}
