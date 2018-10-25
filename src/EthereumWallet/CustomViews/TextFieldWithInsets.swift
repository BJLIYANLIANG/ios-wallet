//
//  TextFieldWithInsets.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 25/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import UIKit

class TextFieldWithInsets: UITextField {

    @IBInspectable var topInset: CGFloat {
        get { return insets.top }
        set { insets.top = newValue }
    }

    @IBInspectable var leftInset: CGFloat {
        get { return insets.left }
        set { insets.left = newValue }
    }

    @IBInspectable var bottomInset: CGFloat {
        get { return insets.bottom }
        set { insets.bottom = newValue }
    }

    @IBInspectable var rightInset: CGFloat {
        get { return insets.right }
        set { insets.right = newValue }
    }

    var insets: UIEdgeInsets = UIEdgeInsets.zero {
        didSet {
            setNeedsLayout()
        }
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return super.textRect(forBounds: bounds).inset(by: insets)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return super.editingRect(forBounds: bounds).inset(by: insets)
    }
}
