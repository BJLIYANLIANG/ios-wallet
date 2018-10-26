//
//  UIViewControllersExtensions.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 23/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import UIKit
import JetLib

protocol AlertPresenter: class {

    @discardableResult
    func showAlert(title: String?, message: String?, ok: String, cancel: String?) -> Task<Bool>
}

extension AlertPresenter {

    @discardableResult
    func showAlert(title: String?) -> Task<Bool> {
        return showAlert(title: title, message: nil, ok: "OK", cancel: nil)
    }

    @discardableResult
    func showAlert(error: Error?) -> Task<Bool> {
        return showAlert(title: "Error", message: error?.localizedDescription, ok: "OK", cancel: nil)
    }

    @discardableResult
    func showAlert(title: String?, message: String?) -> Task<Bool> {
        return showAlert(title: title, message: message, ok: "OK", cancel: nil)
    }
}

extension UIViewController: AlertPresenter {

    @discardableResult
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

    @discardableResult
    func showAlert(title: String?, message: String?, ok: String, cancel: String?) -> Task<Bool> {
        let source = Task<Bool>.Source()
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: ok, style: .default, handler: {(_) in
            try? source.complete(true)
        }))

        if let cancel = cancel {
            alert.addAction(UIAlertAction(title: cancel, style: .cancel, handler: { _ in try? source.cancel() }))
        }

        self.present(alert, animated: true, completion: nil)

        return source.task
    }
}
