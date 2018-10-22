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
    @IBOutlet weak var regularImport: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.view = self
        add(viewModel)

        mnemonicCreate.command = viewModel.createMnemonicCommand
        mnemonicImport.command = viewModel.importMnemonicCommand
        regularCreate.command = viewModel.createKeyCommand
        regularImport.command = viewModel.importKeysCommand
    }
}

extension AddAccountController {

    func resquestMnemonic() -> Task<String> {
        return self.requestValueInAlert(title: "Mnemonic", ok: "Ok", cancel: "Cancel") {
            $0.placeholder = "Mnemonic phrase"
            $0.keyboardType = .alphabet
        }
    }

    func requestAccountIndex() ->Task<Int> {
        return self.requestValueInAlert(title: "Account Index", ok: "Ok", cancel: "Cancel") {
            $0.placeholder = "Index"
            $0.keyboardType = .numberPad
        }.map {
            if let index = Int($0) {
                return index
            } else {
                throw Error.invalidIndex
            }
        }
    }
}

fileprivate enum Error: Swift.Error {
    case invalidIndex
}
