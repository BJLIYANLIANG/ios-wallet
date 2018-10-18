//
//  PinPadViewModel.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 17/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import JetLib

protocol PinpadSymbol: CustomStringConvertible {

    func append(to string: String) -> String
}


class PinPadViewModel: ViewModel<PinPadController> {

    override init() {
        pinCode = PinCode(lenght: 6)
    }

    lazy var appendSymbolCommand = ActionCommand(self) { $0.appendSymbol($1) }

    var pinCode: PinCode {
        didSet {
            view?.showPincode(pinCode)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pinCode.code = ""
    }

    fileprivate func appendSymbol(_ symbol: PinpadSymbol) {
        pinCode.code = symbol.append(to: pinCode.code)

        guard pinCode.isCompleted else  {
            return
        }

        if pinCode.isValid {
            // TODO:
            view?.showDashboard()
            pinCode.code = ""
        } else {
            view?.showWongCode()
            pinCode.code = ""
        }
    }

    struct PinCode {

        init(lenght: Int) {
            self.lenght = lenght
        }

        let lenght: Int

        var currecnt: Int {
            return code.count
        }

        fileprivate var code: String = ""

        var isCompleted: Bool {
            return code.count == lenght
        }

        var isValid: Bool {
            return isCompleted && true // TODO:
        }
    }

    class NumericSymbol: PinpadSymbol {

        var number: Int = 0

        var description: String {
            return number.description
        }

        func append(to string: String) -> String {
            return string + number.description
        }
    }

    class DeleteSymbol: PinpadSymbol {

        var description: String {
            return "Delete"
        }

        func append(to string: String) -> String {
            if string.isEmpty {
                return string
            } else {
                return String(string.prefix(string.count - 1))
            }
        }
    }
}
