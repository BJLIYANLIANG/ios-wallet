//
//  AccountController.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 08/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import UIKit
import JetLib

class AccountController: UIViewController {

    lazy var viewModel: AccountViewModel = container.resolve()

    @IBOutlet weak var accountNumber: UIButton!
    @IBOutlet weak var accountsCard: UIView!
    @IBOutlet weak var accountsPicker: UIPickerView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var balanceActivity: UIActivityIndicatorView!
    @IBOutlet weak var accountCardConstraint: NSLayoutConstraint!

    @IBOutlet weak var newAccountButton: UIButton!
    @IBOutlet weak var mnemonicButton: UIButton!

    var accountCardExpandedHeight: CGFloat!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.translatesAutoresizingMaskIntoConstraints = false

        attach(viewModel)
        //viewModel.view = self

        accountCardExpandedHeight = accountCardConstraint.constant
        accountCardConstraint.constant = 0

        accountsCard.isHidden = true
//        accountsPicker.delegate = self
//        accountsPicker.dataSource = self

        //accountNumber.command = ActionCommand(self) { $0.hideShowPicker() }
        //newAccountButton.command = ActionCommand(self) { $0.viewModel.createNewAccount() }
        //mnemonicButton.command = ActionCommand(self) { $0.viewModel.addMnemonicAccount() }
    }

    func hideShowPicker(show: Bool? = nil) {
        if show == !accountsCard.isHidden {
            return
        }

        accountsCard.isHidden = !accountsCard.isHidden
        accountCardConstraint.constant = accountsCard.isHidden ? 0 : accountCardExpandedHeight

        UIView.animate(withDuration: UIContants.animationDuration) {
            self.view.layoutIfNeeded()
            self.parent?.view.layoutIfNeeded()
        }
    }
}
//
//extension AccountController: AccountView {
//
//    func balanceChanged() {
//        balanceActivity.displayIf(nil: viewModel.balance)
//        balanceLabel.text = "Balance: \(viewModel.balance ?? "-")"
//    }
//
//    func accountChanged() {
//        accountNumber.setTitle("Account: \(viewModel.selected?.address ?? "-")", for: .normal)
//    }
//
//
//    func accountsCollectionChanged() {
//        accountsPicker.reloadAllComponents()
//    }
//}

extension AccountController {

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
//
//extension AccountController: UIPickerViewDataSource, UIPickerViewDelegate {
//
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return viewModel.accounts?.count ?? 0
//    }
//
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        viewModel.selected = viewModel.accounts?[row]
//    }
//
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return viewModel.accounts?[row].numberTrancatedInMiddle()
//    }
//}
//
