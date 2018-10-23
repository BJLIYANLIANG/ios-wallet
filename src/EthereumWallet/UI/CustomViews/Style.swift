//
//  Style.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 23/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import UIKit

class Style {

    static func initAppearances() {
        let inputBackColor = UIColor(red: 250.0/255, green: 250.0/255, blue: 250.0/255, alpha: 1)

        UITextField.appearance().backgroundColor = inputBackColor
        UITextField.appearance().clipsToBounds = true
        UITextField.appearance().cornerRadius = 8
        UITextField.appearance().borderColor = inputBackColor
        UITextField.appearance().borderWidth = 2

        UITextView.appearance().backgroundColor = inputBackColor
        UITextView.appearance().cornerRadius = 8
        UITextView.appearance().borderColor = inputBackColor
        UITextView.appearance().borderWidth = 2
    }
}


