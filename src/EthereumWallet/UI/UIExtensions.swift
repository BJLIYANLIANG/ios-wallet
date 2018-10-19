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

extension ViewModel {

    func reload(force: Bool = false) {
        guard force else {
            self.dataUpdateRequested(initiator: self)
            return
        }

        cancelAll().notify(queue: DispatchQueue.main) {
            self.dataUpdateRequested(initiator: self)
        }
    }
}

extension UIViewController {

    @discardableResult
    func attach(_ viewModel: ViewModel) -> ViewModel {
        add(viewModel)
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

    func showAlert(title: String?, message: String? = nil,
                   ok: String = "OK", cancel: String? = nil) -> Task<Bool> {
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

public extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
