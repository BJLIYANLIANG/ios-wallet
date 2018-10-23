//
//  CreateMnemonicKeyController.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 23/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import UIKit
import JetLib

class CreateMnemonicKeyController: UIViewController {

    lazy var viewModel: CreateMnemonicKeyViewModel = container.resolve()

    @IBOutlet weak var mnemonicTextView: UITextView!
    @IBOutlet weak var mnemonicTextError: UILabel!
    @IBOutlet weak var mnemonicTextPlaceholderLabel: UILabel!
    @IBOutlet weak var confirmTextView: UITextView!
    @IBOutlet weak var confirmTextError: UILabel!
    @IBOutlet weak var confirmTextPlaceholderLabel: UILabel!

    @IBOutlet weak var saveButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.view = self
        saveButton.command = viewModel.createCommand
        mnemonicTextView.delegate = self
        confirmTextView.delegate = self
        mnemonicTextError.isHidden = true
        confirmTextError.isHidden = true
    }
}

extension CreateMnemonicKeyController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        switch textView {
        case mnemonicTextView:
            mnemonicTextPlaceholderLabel.isVisible = textView.text.isEmpty
            viewModel.errors.mnemonicText = nil
        case confirmTextView:
            confirmTextPlaceholderLabel.isVisible = textView.text.isEmpty
            viewModel.errors.mnemonicConfirmation = nil
        default:
            break
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text != "\n" else {
            if textView == mnemonicTextView {
                confirmTextView.becomeFirstResponder()
            } else {
                view.endEditing(true)
            }

            return false
        }

        return true
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        switch textView {
        case mnemonicTextView:
            viewModel.mnemonicParams.mnemonicText = textView.text
        case confirmTextView:
            viewModel.mnemonicParams.confirmationText = textView.text
        default:
            break
        }
        return true
    }
}

extension CreateMnemonicKeyController {

    func display(errors: CreateMnemonicKeyViewModel.Errors) {
        mnemonicTextError.text = errors.mnemonicText
        mnemonicTextError.isHidden = errors.mnemonicText == nil

        confirmTextError.text =  errors.mnemonicConfirmation
        confirmTextError.isHidden = errors.mnemonicConfirmation == nil
    }
}
