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

        add(accountViewModel)

        accountViewModel.view = self

        addAccountCountroller?.viewModel.onAccountAdded = { [weak self] in
            self?.accountViewModel.reload(force: true)
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
        emptyView.isVisible = viewModel.account == nil
        rootScrollView?.isVisible = viewModel.account != nil
        accountAddressLabel.text = viewModel.account?.address
        transactionListController?.viewModel.account = viewModel.account
    }
}
