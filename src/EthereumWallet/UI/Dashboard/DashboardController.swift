//
//  DashboardController.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 15/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import UIKit
import JetLib

class DashboardController: UIViewController {

    lazy var accountViewModel: AccountViewModel = container.resolve()
    lazy var accountListViewModel: AccountListViewModel = container.resolve()

    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var rootScrollView: RootScrollView?
    @IBOutlet weak var accountAddressLabel: UILabel!

    var transactionListController: TransactionListController? {
        return children.first(where: { $0 is TransactionListController }) as? TransactionListController
    }

    var addAccountCountroller: AddAccountController? {
        return children.first(where: { $0 is AddAccountController }) as? AddAccountController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        add(accountListViewModel)
        add(accountViewModel)

        accountViewModel.view = self
        accountListViewModel.view = self

        rootScrollView?.nestedScrollView =  transactionListController?.tableView

        addAccountCountroller?.viewModel.onAccountAdded = { [weak self] in
            self?.accountListViewModel.reload(force: true)
        }
    }
}

extension DashboardController: AccountView {

    func balanceChanged(_ viewModel: AccountViewModel) {

    }

    func accountChanged(_ viewModel: AccountViewModel) {
        accountAddressLabel.text = viewModel.account?.address
    }
}

extension DashboardController: AccountListView {

    func collectionChanged(_ viewModel: AccountListViewModel) {
        emptyView.isVisible = viewModel.accounts?.isEmpty == true
        rootScrollView?.isVisible = viewModel.accounts?.isEmpty == false
    }

    func selcetedChanged(_ viewModel: AccountListViewModel) {
        accountViewModel.account = viewModel.selected
        transactionListController?.viewModel.account = viewModel.selected
    }
}
