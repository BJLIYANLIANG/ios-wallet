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

    lazy var viewModel: PinPadViewModel = container.resolve()

    @IBOutlet var numberButtons: [RoundedBlurButton]!
    @IBOutlet weak var biometricLoginButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var dotsStack: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()

        attach(viewModel)

        for pair in numberButtons.enumerated() {
            let symbol = PinPadViewModel.NumericSymbol()
            symbol.number = pair.offset
            let button = pair.element
            button.setBackgroundImage(UIImage(color: UIColor.white.withAlphaComponent(0.25)), for: .normal)
            button.setBackgroundImage(UIImage(color: UIColor.black.withAlphaComponent(0.5)), for: .highlighted)
            button.setBackgroundImage(UIImage(color: UIColor.black.withAlphaComponent(0.5)), for: .selected)
            button.setTitle(symbol.description, for: .normal)
            button.commanParameter = symbol
            button.command = viewModel.appendSymbolCommand
        }

        deleteButton.commanParameter = PinPadViewModel.DeleteSymbol()
        deleteButton.command = viewModel.appendSymbolCommand
    }
}

extension PinPadController {

    func showDashboard() {
        let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
        let controller = storyboard.instantiateInitialViewController()!
        self.present(controller, animated: true, completion: {})
    }

    func showWongCode() {

    }

    func showPincode(_ pincode: PinPadViewModel.PinCode) {
        while dotsStack.arrangedSubviews.count > pincode.lenght {
            dotsStack.removeArrangedSubview(dotsStack.arrangedSubviews.last!)
        }

        while dotsStack.subviews.count < pincode.lenght {
            let imageView = UIImageView()
            imageView.contentMode = .scaleToFill
            dotsStack.addArrangedSubview(imageView)
            imageView.heightAnchor.constraint(equalTo: dotsStack.heightAnchor).isActive = true
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
        }

        for pair in dotsStack.arrangedSubviews.enumerated() {
            let image: UIImage? = pair.offset < pincode.currecnt ? #imageLiteral(resourceName: "icon_logo_white") : #imageLiteral(resourceName: "icon_faceid")
            (pair.element as? UIImageView)?.image = image
        }
    }
}
