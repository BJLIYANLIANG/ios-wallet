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

    @IBOutlet weak var regularView: UIView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var accountAddressLabel: UILabel!
    @IBOutlet weak var accountBalanceLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var contractButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var copyAddressButton: UIButton!
    @IBOutlet weak var noTransactionsView: UIView!
    @IBOutlet weak var headerView: UIView!

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
            self?.accountViewModel.account = self?.accountViewModel.accountsRepo.selected
            self?.showAlert(title: "Your wallet has been created!")
            self?.navigationController?.setNavigationBarHidden(true, animated: true)
        }

        copyAddressButton.command = accountViewModel.copyAddressCommand

        sendButton.command = ActionCommand.pushScreen(self, sbName: "Transactions", controllerId: "sendTransaction")
        contractButton.command = ActionCommand.pushScreen(self, sbName: "Contracts", controllerId: "executeContract")
        settingButton.command = ActionCommand.pushScreen(self, sbName: "Settings", controllerId: "settings")

        transactionListController?.tableView?.insertSubview(refresher, at: 0)
        refresher.addTarget(self, action: #selector(handleRefresher), for: .valueChanged)

        transactionListController?.noTransactionsView = noTransactionsView
        transactionListController?.tableView.tableHeaderView = headerView
        transactionListController?.tableView.widthAnchor.constraint(equalTo: headerView.widthAnchor).isActive = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(accountViewModel.account != nil, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

       transactionListController?.snapToOffsets = [
            accountBalanceLabel.convert(CGPoint.zero, to: headerView).y,
            sendButton.convert(CGPoint.zero, to: headerView).y - 16,
            headerView.bounds.height
        ]
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let accountList = segue.destination as? AccountListController {
            accountList.delegate = accountViewModel
        }
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
        self.navigationItem.title = viewModel.account == nil ? "Add new wallet" : "Dashboard"
        regularView?.isVisible = viewModel.account != nil
        accountAddressLabel.text = viewModel.account?.address
        transactionListController?.viewModel.account = viewModel.account
    }
}
