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

    var transactionListController: TransactionListController? {
        return children.first(where: { $0 is TransactionListController}) as? TransactionListController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        add(accountListViewModel)
        add(accountViewModel)

        accountViewModel.view = self
        accountListViewModel.view = self

        rootScrollView?.nestedScrollView =  transactionListController?.tableView
    }
}

extension DashboardController: AccountView {

    func balanceChanged(_ viewModel: AccountViewModel) {

    }

    func accountChanged(_ viewModel: AccountViewModel) {

    }
}

extension DashboardController: AccountListView {

    func collectionChanged(_ viewModel: AccountListViewModel) {
        emptyView.isHidden = !(viewModel.accounts?.isEmpty == false)
        rootScrollView?.isHidden = viewModel.accounts?.isEmpty == false
    }

    func selcetedChanged(_ viewModel: AccountListViewModel) {
        accountViewModel.account = viewModel.selected
        transactionListController?.viewModel.account = viewModel.selected
    }
}
