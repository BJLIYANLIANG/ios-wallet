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
    @IBOutlet weak var accountBalanceLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var contractButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!

    let refresher: UIRefreshControl = UIRefreshControl()

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

        addAccountCountroller?.viewModel.onAccountAdded = { [weak self] in
            self?.accountListViewModel.reload(force: true)
        }

        sendButton.command = ActionCommand.pushScreen(self, sbName: "Transactions", controllerId: "sendTransaction")
        contractButton.command = ActionCommand.pushScreen(self, sbName: "Contracts", controllerId: "executeContract")
        settingButton.command = ActionCommand.pushScreen(self, sbName: "Settings", controllerId: "settings")

        rootScrollView?.nestedScrollView =  transactionListController?.tableView
        rootScrollView?.insertSubview(refresher, at: 0)

        refresher.addTarget(self, action: #selector(handleRefresher), for: .valueChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

       rootScrollView?.snapToOffsets = [
            accountBalanceLabel.convert(CGPoint.zero, to: rootScrollView).y,
            sendButton.convert(CGPoint.zero, to: rootScrollView).y - 16,
            transactionListController!.view.convert(CGPoint.zero, to: rootScrollView).y
        ]
    }

    @objc
    fileprivate func handleRefresher(_ sender: UIRefreshControl) {
        let group = DispatchGroup()
        accountViewModel.dataUpdateRequested(initiator: group)
        transactionListController?.viewModel.dataUpdateRequested(initiator: group)

        group.notify(queue: DispatchQueue.main) {
            sender.endRefreshing()
        }
    }
}

extension DashboardController: AccountView {

    func balanceChanged(_ viewModel: AccountViewModel) {
        accountBalanceLabel.text = viewModel.balance?.description
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

    func selectedChanged(_ viewModel: AccountListViewModel) {
        accountViewModel.account = viewModel.selected
        transactionListController?.viewModel.account = viewModel.selected
    }
}
