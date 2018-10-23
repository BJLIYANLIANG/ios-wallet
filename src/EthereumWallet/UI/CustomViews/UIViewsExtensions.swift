//
//  UIViewsExtensions.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 23/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import UIKit

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

public extension UITextField {

    @IBInspectable var placeholderColor: UIColor? {
        get { return self.placeholderColor }
        set {
            let placeholderString = self.placeholder != nil ? self.placeholder! : ""
            self.attributedPlaceholder = NSAttributedString(string: placeholderString, attributes: [NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
}

public extension UIView {

    var isVisible: Bool {
        get { return !isHidden }
        set { isHidden = !newValue }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get { return self.layer.borderWidth }
        set { self.layer.borderWidth = newValue }
    }

    @IBInspectable var borderColor: UIColor? {
        get { return self.layer.borderColor == nil ? UIColor(cgColor: self.layer.borderColor!) as UIColor? : (nil as UIColor?) }
        set { self.layer.borderColor = newValue?.cgColor }
    }

    @IBInspectable var cornerRadius: CGFloat {
        get { return self.layer.cornerRadius }
        set { self.layer.cornerRadius = newValue }
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
