//
//  UIExtensions.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 08/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import UIKit
import JetLib

extension UIViewController {

    @discardableResult
    func attach<T: UIViewController>(_ viewModel: ViewModel<T>) -> ViewModel<T> {
        defer {
            add(viewModel)
        }

        guard let view = self as? T else {
            print("ERROR: view and viewModel types mistmath")
            return viewModel
        }

        viewModel.view = view

        return viewModel
    }

    func endEditing() {
        view.endEditing(true)
    }
}

extension UIActivityIndicatorView {

    func displayIf<T>(nil value: T?) {
        self.hidesWhenStopped = true

        if value == nil {
            self.startAnimating()
        } else {
            self.stopAnimating()
        }
    }
}


extension UIViewController {

    func requestValueInAlert(title: String?, message: String? = nil,
                             ok: String = "OK", cancel: String? = nil,
                             configurationHandler: ((UITextField) -> Void)? = nil) -> Task<String> {
        let source = Task<String>.Source()

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField(configurationHandler: configurationHandler)
        alert.addAction(UIAlertAction(title: ok, style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            try? source.complete(textField?.text ?? "")
        }))

        if let cancel = cancel {
            alert.addAction(UIAlertAction(title: cancel, style: .cancel, handler: { _ in try? source.cancel() }))
        }

        self.present(alert, animated: true, completion: nil)

        return source.task
    }
}
