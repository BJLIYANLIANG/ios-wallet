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

    @IBOutlet weak var mnemonicTextView: UITextView!
    @IBOutlet weak var mnemonicTextError: UILabel!
    @IBOutlet weak var mnemonicTextPlaceholderLabel: UILabel!
    @IBOutlet weak var accountNumberField: UITextField!
    @IBOutlet weak var mnemonicNumberError: UILabel!

    @IBOutlet weak var saveButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.view = self
        saveButton.command = viewModel.createCommand
        mnemonicTextView.delegate = self
        accountNumberField.delegate = self
        mnemonicTextError.isHidden = true
        mnemonicNumberError.isHidden = true
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
        mnemonicTextPlaceholderLabel.isVisible = textView.text.isEmpty
        viewModel.errors.textError = nil
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text != "\n" else {
            accountNumberField.becomeFirstResponder()
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
        mnemonicNumberError.text = errors.indexError
        mnemonicTextError.text = errors.textError
        mnemonicTextError.isHidden = errors.textError == nil
        mnemonicNumberError.isHidden = errors.indexError == nil
    }
}
