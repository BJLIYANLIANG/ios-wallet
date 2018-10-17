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

    private let pinCode = PinCode()

    override init() {

    }

    lazy var appendSymbolCommand = ActionCommand(self) { $0.appendSymbol($1) }

    fileprivate func appendSymbol(_ symbol: PinpadSymbol) {
        pinCode.code = symbol.append(to: pinCode.code)

        view?.showPincode(pinCode)

        guard pinCode.isCompleted else  {
            return
        }

        if pinCode.isValid {
            view?.showDashboard()
        } else {
            view?.showWongCode()
        }
    }

    class PinCode {

        init() {
        }

        let lenght: Int = 6

        var currecnt: Int {
            return code.count
        }

        fileprivate var code: String = ""

        var isCompleted: Bool {
            return code.count == lenght
        }

        var isValid: Bool {
            return isCompleted && true
        }
    }

    struct NumericSymbol: PinpadSymbol {

        let number: Int

        var description: String {
            return number.description
        }

        func append(to string: String) -> String {
            return string + number.description
        }
    }

    struct DeleteSymbol: PinpadSymbol {

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
