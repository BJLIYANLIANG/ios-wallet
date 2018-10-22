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

protocol AlertPresenter {

    @discardableResult
    func showAlert(title: String?, message: String?, ok: String, cancel: String?) -> Task<Bool>
}

extension AlertPresenter {

    @discardableResult
    func showAlert(title: String?) -> Task<Bool> {
        return showAlert(title: title, message: nil, ok: "OK", cancel: nil)
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

public extension UIView {

    var isVisible: Bool {
        get { return !isHidden }
        set { isHidden = !newValue }
    }
}

public extension UIButton {

    @IBInspectable var pressedBackImage: UIImage? {
        get { return backgroundImage(for: .highlighted) }
        set { return setBackgroundImage(newValue, for: .highlighted) }
    }

    @IBInspectable var pressedImage: UIImage? {
        get { return image(for: .highlighted) }
        set { return setImage(newValue, for: .highlighted) }
    }
}

extension ActionCommand {

    static func pushScreen(_ from: UIViewController, sbName: String, controllerId: String) -> ActionCommand {
        return ActionCommand(from) {
            let storyboard = UIStoryboard(name: "Transactions", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "sendTransaction")
            $0.navigationController?.pushViewController(controller, animated: true)
        }
    }

    static func pushScreen(_ from: UIViewController, create: @escaping () -> UIViewController) -> ActionCommand {
        return ActionCommand(from) {
            $0.navigationController?.pushViewController(create(), animated: true)
        }
    }
}
