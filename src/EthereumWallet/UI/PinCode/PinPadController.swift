//
//  PinPadController.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 17/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import UIKit
import JetLib

class PinPadController: UIViewController {

    @IBOutlet var numberButtons: [RoundedBlurButton]!

    override func viewDidLoad() {
        super.viewDidLoad()

        for pair in numberButtons.enumerated() {
            let symbol = PinPadViewModel.NumericSymbol(number: pair.offset)
            let button = pair.element
            button.setBackgroundImage(UIImage(color: UIColor.white.withAlphaComponent(0.25)), for: .normal)
            button.setBackgroundImage(UIImage(color: UIColor.black.withAlphaComponent(0.5)), for: .highlighted)
            button.setBackgroundImage(UIImage(color: UIColor.black.withAlphaComponent(0.5)), for: .selected)
            button.setTitle(symbol.description, for: .normal)
            button.commanParameter = symbol
        }
    }
}

extension UIButton {

    func addShadow() {
        layer.shadowColor = UIColor.blue.cgColor
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 8
        layer.masksToBounds = false
        layer.shadowOpacity = 0.5
    }
}

extension PinPadController {

    func showDashboard() {

    }

    func showWongCode() {

    }

    func showPincode(_ pincode: PinPadViewModel.PinCode) {

    }
}
