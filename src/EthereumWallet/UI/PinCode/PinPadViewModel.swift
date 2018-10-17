//
//  PinPadViewModel.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 17/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import JetLib

protocol PinpadSymbol {

    func append(to string: String) -> String
}


class PinPadViewModel: ViewModel<PinPadController> {

    let pinCode = PinCode()

    func appendSymbol(_ symbol: PinpadSymbol) {
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

        let currecnt: Int {
            return code.count
        }

        fileprivate var code: String = ""

        var isCompleted: Bool {
            return code.count == lenght
        }

        var isValid: Bool {
            return isCompleted &&
        }
    }

    struct NumericSymbol: PinpadSymbol {

        var number: Int

        init(number: Int) {
            self.number = number
        }

        func append(to string: String) -> String {
            return string + number.description
        }
    }

    struct DeleteSymbol: PinpadSymbol {

        func append(to string: String) -> String {
            if string.isEmpty {
                return string
            } else {
                return String(string.prefix(string.count - 1))
            }
        }
    }
}
