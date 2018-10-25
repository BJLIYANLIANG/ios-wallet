//
//  SendTransactionController.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 22/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import UIKit
import JetLib

class SendTransactionController: UIViewController {

    lazy var viewModel: SendTransactionViewModel = container.resolve()
    lazy var accountList: AccountListViewModel = container.resolve()
    lazy var accountBalance: AccountViewModel = container.resolve()

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var fromField: UITextField!
    @IBOutlet weak var fromPicker: UIPickerView!
    @IBOutlet weak var fromErrorView: UIStackView!
    @IBOutlet weak var fromErrorLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!

    @IBOutlet weak var targetField: UITextField!
    @IBOutlet weak var targetErrorView: UIStackView!
    @IBOutlet weak var targetErrorLabel: UILabel!

    @IBOutlet weak var amountField: UITextField!
    @IBOutlet weak var amountErrorView: UIStackView!
    @IBOutlet weak var amountErrorLabel: UILabel!

    @IBOutlet weak var sendButton: ShadowButton!
    @IBOutlet weak var scanButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        accountList.storeSelection = false
        add(accountList)
        add(accountBalance)
        add(viewModel)
        viewModel.view = self
        accountList.view = self
        accountBalance.view = self

        fromPicker.isHidden = true
        hideAllErrors()
        targetField.delegate = self
        fromField.delegate = self
        amountField.delegate = self
        fromPicker.dataSource = self
        fromPicker.delegate = self

        hideKeyboardWhenTappedAround()
        adjustKeyboardInsets(to: scrollView)

        sendButton.command = viewModel.sendTransactionCommand
        scanButton.command = ActionCommand(self) {
            let controller = QRCodeScanerController()
            let decorated = UINavigationController(rootViewController: controller)
            controller.delegate = $0.viewModel
            $0.present(decorated, animated: true, completion: nil)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func dismissKeyboard() {
        super.dismissKeyboard()
        fromPicker.isHidden = true
    }

    fileprivate func hideAllErrors() {
        fromErrorView.isHidden = true
        targetErrorView.isHidden = true
        amountErrorView.isHidden = true
    }
}

extension SendTransactionController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return accountList.accounts?.count ?? 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return accountList.accounts?[row].addressTrancatedInMiddle()
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        accountList.selected = accountList.accounts?[row]
    }
}

extension SendTransactionController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let oldHidden = fromPicker.isHidden
        defer {
            if oldHidden != fromPicker.isHidden {
                UIView.animate(withDuration: 0.250, animations: {
                    self.view.layoutSubviews()
                })
            }
        }

        if textField == fromField {
            fromPicker.isHidden = false
            return false
        } else {
            fromPicker.isHidden = true
            return true
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case amountField:
            viewModel.amountString = amountField.text
        case targetField:
            viewModel.to = targetField.text
        default:
            break
        }
    }
}

extension SendTransactionController {

    func fromChanged(_ viewModel: SendTransactionViewModel) {
        fromField.text = viewModel.from?.address
    }

    func toChanged(_ viewModel: SendTransactionViewModel) {
        targetField.text = viewModel.to
    }

    func amountChanged(_ viewModel: SendTransactionViewModel) {
        amountField.text = viewModel.amount?.description
    }

    func showError(_ error: Error) {
        guard let validationsError = error as? SendTransactionViewModel.Errors else {
            showAlert(title: error.localizedDescription)
            return
        }

        hideAllErrors()

        switch validationsError {
        case .noFrom:
            fromErrorLabel.text = validationsError.localizedDescription
            fromErrorView.isHidden = false
        case .noTo:
            targetErrorLabel.text = validationsError.localizedDescription
            targetErrorView.isHidden = false
        case .wrongAmount:
            amountErrorLabel.text = validationsError.localizedDescription
            amountErrorView.isHidden = false
        default:
            showAlert(title: error.localizedDescription)
        }
    }
}

extension SendTransactionController: AccountListView {

    func collectionChanged(_ viewModel: AccountListViewModel) {
        fromPicker.reloadAllComponents()
    }

    func selectedChanged(_ viewModel: AccountListViewModel) {
        self.viewModel.from = viewModel.selected
        self.accountBalance.account = viewModel.selected
    }
}

extension SendTransactionController: AccountView {

    func balanceChanged(_ viewModel: AccountViewModel) {
        balanceLabel.text = viewModel.balance?.description ?? " - "
    }

    func accountChanged(_ viewModel: AccountViewModel) {
    }
}
