//
//  DashboardController.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 15/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import UIKit

class DashboardController: UIViewController {

    var accoutController: AccountController? {
        return children.first(where: { $0 is AccountController}) as? AccountController
    }

    var transactionListController: TransactionListController? {
        return children.first(where: { $0 is TransactionListController}) as? TransactionListController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        accoutController?.viewModel.delegate = transactionListController
    }
}
