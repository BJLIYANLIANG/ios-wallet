//
//  ImportMnemonicKeyController.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 23/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import UIKit
import JetLib

class ImportMnemonicKeyController: UIViewController {

    lazy var viewModel: ImportMnemonicKeyViewModel = container.resolve()

    @IBOutlet weak var mnemonicField: UITextView!
    @IBOutlet weak var mnemonicErrorLabel: UILabel!
    @IBOutlet weak var mnemonicErrorView: UIStackView!
    @IBOutlet weak var mnemonicPlaceholderLabel: UILabel!
    @IBOutlet weak var indexField: UITextField!
    @IBOutlet weak var indexErrorLabel: UILabel!
    @IBOutlet weak var indexErrorView: UIStackView!

    @IBOutlet weak var saveButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.view = self
        saveButton.command = viewModel.createCommand
        mnemonicField.delegate = self
        indexField.delegate = self
        mnemonicErrorView.isHidden = true
        indexErrorView.isHidden = true
    }
}

extension ImportMnemonicKeyController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        viewModel.errors.indexError = nil
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        viewModel.mnemonicParams.keyIndex = textField.text == nil ? nil : Int(textField.text!)
    }
}

extension ImportMnemonicKeyController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        mnemonicPlaceholderLabel.isVisible = textView.text.isEmpty
        viewModel.errors.mnemonicError = nil
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text != "\n" else {
            indexField.becomeFirstResponder()
            return false
        }

        return true
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        viewModel.mnemonicParams.mnemonicText = textView.text
        return true
    }
}

extension ImportMnemonicKeyController {

    func display(errors: ImportMnemonicKeyViewModel.Errors) {
        indexErrorLabel.text = errors.indexError
        mnemonicErrorLabel.text = errors.mnemonicError
        mnemonicErrorView.isHidden = errors.mnemonicError == nil
        indexErrorView.isHidden = errors.indexError == nil
    }
}
