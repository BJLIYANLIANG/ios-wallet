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

    @IBOutlet var numberButtons: [UIButton]!
    @IBOutlet weak var biometricLoginButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var dotsStack: UIStackView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var logoStack: UIStackView!
    @IBOutlet weak var logoLabel: UILabel!
    @IBOutlet weak var logoIcon: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.view = self
        add(viewModel)

        for pair in numberButtons.enumerated() {
            let symbol = PinPadViewModel.NumericSymbol()
            let button = pair.element
            symbol.number = pair.offset
            button.setBackgroundImage(#imageLiteral(resourceName: "pinpad-button"), for: .normal)
            button.setBackgroundImage(#imageLiteral(resourceName: "pinpad-button-pressed"), for: .highlighted)
            button.setTitle(symbol.description, for: .normal)
            button.commanParameter = symbol
            button.command = viewModel.appendSymbolCommand
        }

        biometricLoginButton.command = viewModel.biometricLoginCommand
        deleteButton.commanParameter = PinPadViewModel.DeleteSymbol()
        deleteButton.command = viewModel.appendSymbolCommand

        deleteButton.setImage(#imageLiteral(resourceName: "clear-pin-button"), for: .normal)
        deleteButton.setImage(#imageLiteral(resourceName: "clear-pin-button-pressed"), for: .highlighted)

        if min(UIScreen.main.bounds.size.height, UIScreen.main.bounds.size.width) < 375 {
            logoStack.axis = .horizontal
            logoLabel.font = logoLabel.font.withSize(18)
            logoIcon.image = #imageLiteral(resourceName: "logo-white-small")
            messageLabel.font = messageLabel.font.withSize(15)
        }
    }
}

extension PinPadController {

    func showDashboard() {
        let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
        let controller = storyboard.instantiateInitialViewController()!
        self.present(controller, animated: true, completion: {})
    }

    func showMessage(_ show: Bool) {
        messageLabel.isHidden = !show
    }

    func showBiometric(_ type: LocalLoginService.BiometricType) {
        switch type {
        case .faceId:
            biometricLoginButton.setImage(#imageLiteral(resourceName: "face-id"), for: .normal)
            biometricLoginButton.setImage(#imageLiteral(resourceName: "face-id-pressed"), for: .highlighted)
            biometricLoginButton.isHidden = false
        case .touchId:
            biometricLoginButton.setImage(#imageLiteral(resourceName: "touch-id"), for: .normal)
            biometricLoginButton.setImage(#imageLiteral(resourceName: "touch-id-pressed"), for: .highlighted)
            biometricLoginButton.isHidden = false
        default:
            biometricLoginButton.isHidden = true
        }
    }

    func showWongCode() {
        // TODO: alert or animation
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
            let image: UIImage? = pair.offset < pincode.currecnt ? #imageLiteral(resourceName: "pin-code-circle-filled") : #imageLiteral(resourceName: "pin-code-circle")
            (pair.element as? UIImageView)?.image = image
        }
    }
}
