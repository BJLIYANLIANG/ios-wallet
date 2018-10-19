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

private protocol PinPadState {

    var hasMessage: Bool { get }

    func biometricType(viewModel: PinPadViewModel) -> LocalLoginService.BiometricType
    func processPinCode(viewModel: PinPadViewModel)
    func willAppear(viewModel: PinPadViewModel)
}

class PinPadViewModel: ViewModel {

    private let loginService: LocalLoginService

    init(loginService: LocalLoginService) {
        self.pinCode = PinCode(lenght: 6)
        self.loginService = loginService
        self.state = SetCodeState()
    }

    weak var view: PinPadController?

    lazy var appendSymbolCommand = ActionCommand(self) { $0.appendSymbol($1) }

    lazy var biometricLoginCommand = AsyncCommand(self, task: { $0.biometricLogin() },
                                                  canExecute: { $0.loginService.isAvailableBiometric })

    fileprivate var pinCode: PinCode {
        didSet {
            view?.showPincode(pinCode)
        }
    }

    fileprivate var state: PinPadState {
        didSet {
            view?.showMessage(state.hasMessage)
            view?.showBiometric(state.biometricType(viewModel: self))
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        state = loginService.isPincodeInited ? LoginState() : SetCodeState()
        state.willAppear(viewModel: self)
    }

    fileprivate func biometricLogin() -> Task<Bool> {
        return submit(task: loginService.biometricLogin().notify { [weak self] in
            if $0.result == true {
                self?.view?.showDashboard()
            }
        })
    }

    fileprivate func appendSymbol(_ symbol: PinpadSymbol) {
        pinCode.code = symbol.append(to: pinCode.code)

        guard pinCode.isCompleted else  {
            return
        }

        state.processPinCode(viewModel: self)
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

    fileprivate class LoginState: PinPadState {

        let hasMessage = false

        func biometricType(viewModel: PinPadViewModel) -> LocalLoginService.BiometricType {
            return viewModel.loginService.isBiometricLoginPreffered
                ? viewModel.loginService.biometricType
                : LocalLoginService.BiometricType.none
        }

        func willAppear(viewModel: PinPadViewModel) {
            viewModel.pinCode.code = ""

            if viewModel.loginService.isBiometricLoginPreffered {
                viewModel.biometricLoginCommand.execute()
            }
        }

        func processPinCode(viewModel: PinPadViewModel) {
            if viewModel.loginService.pincodeLogin(pincode: viewModel.pinCode.code) {
                viewModel.view?.showDashboard()
                viewModel.pinCode.code = ""
            } else {
                viewModel.view?.showWongCode()
                viewModel.pinCode.code = ""
            }
        }
    }

    fileprivate class SetCodeState: PinPadState {

        let hasMessage = true

        func willAppear(viewModel: PinPadViewModel) {
            viewModel.pinCode.code = ""
        }

        func biometricType(viewModel: PinPadViewModel) -> LocalLoginService.BiometricType {
            return .none
        }

        func processPinCode(viewModel: PinPadViewModel) {
            try! viewModel.loginService.setPinCode(pincode: viewModel.pinCode.code)

            guard viewModel.loginService.biometricType != .none else {
                viewModel.view?.showDashboard()
                return
            }

            viewModel.view?.showAlert(
                title: "<TODO> login via biometric",
                message: "<TODO> Do you want use \(viewModel.loginService.biometricType)?",
                ok: "Yes", cancel: "No")
            .onSuccess { [weak viewModel] (_) in
                viewModel?.loginService.isBiometricLoginPreffered = true
            }.notify { [weak viewModel] (_) in
                viewModel?.view?.showDashboard()
            }
        }
    }
}
