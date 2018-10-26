//
//  Container.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 08/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import DITranquillity

private var scopes = [newContainer()]

var container: DIContainer {
    return scopes.last!
}

extension DIContainer {

    func newScope() -> DIContainer {
        scopes.append(newContainer())
        return container
    }

    func popScope() {
        if scopes.count > 1 {
            scopes.removeLast()
        }
    }
}

private func newContainer() -> DIContainer {
    let container = DIContainer()

    container.register(KeystoreProxy.init).lifetime(.perContainer(.strong))
    container.register1(KeystoreAccountProvider.init).lifetime(.perContainer(.strong))
    container.register(AccountRepository.init).lifetime(.perContainer(.strong))
    container.register(LocalLoginService.init).lifetime(.perContainer(.strong))
    container.register(TransactionService.init).lifetime(.perContainer(.strong))
    container.register(AccountBalanceRepository.init).lifetime(.perContainer(.strong))
    container.register(TransactionHistostyRepository.init).lifetime(.perContainer(.strong))

    container.register(SettingsViewModel.init).lifetime(.objectGraph)
    container.register1(SendTransactionViewModel.init).lifetime(.objectGraph)
    container.register1(CreateMnemonicKeyViewModel.init).lifetime(.objectGraph)
    container.register1(ImportMnemonicKeyViewModel.init).lifetime(.objectGraph)
    container.register1(AddAccountViewModel.init).lifetime(.objectGraph)
    container.register1(PinPadViewModel.init).lifetime(.objectGraph)
    container.register(AccountViewModel.init).lifetime(.objectGraph)
    container.register1(AccountListViewModel.init).lifetime(.objectGraph)
    container.register1(TransactionListViewModel.init).lifetime(.objectGraph)

    #if DEBUG
    precondition(container.validate())
    #endif

    return container
}
