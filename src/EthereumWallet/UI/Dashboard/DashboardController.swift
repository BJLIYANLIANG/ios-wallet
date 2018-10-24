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

class DashboardController: SlideMenuViewController {

    lazy var accountViewModel: AccountViewModel = container.resolve()

    @IBOutlet weak var regularView: UIView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var rootScrollView: RootScrollView?
    @IBOutlet weak var accountAddressLabel: UILabel!
    @IBOutlet weak var accountBalanceLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var contractButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var copyAddressButton: UIButton!
    @IBOutlet weak var noTransactionsView: UIView!

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
            self?.showAlert(title: "Your wallet has been created!")
        }

        copyAddressButton.command = accountViewModel.copyAddressCommand

        sendButton.command = ActionCommand.pushScreen(self, sbName: "Transactions", controllerId: "sendTransaction")
        contractButton.command = ActionCommand.pushScreen(self, sbName: "Contracts", controllerId: "executeContract")
        settingButton.command = ActionCommand.pushScreen(self, sbName: "Settings", controllerId: "settings")

        rootScrollView?.nestedScrollView =  transactionListController?.tableView
        rootScrollView?.insertSubview(refresher, at: 0)

        refresher.addTarget(self, action: #selector(handleRefresher), for: .valueChanged)

        let accountStoryboard = UIStoryboard(name: "Account", bundle: nil)
        let accountList = accountStoryboard.instantiateViewController(withIdentifier: "accountList") as! AccountListController
        panMenuFromLeft = true
        menuController = accountList
        accountList.delegate = accountViewModel

        transactionListController?.noTransactionsView = noTransactionsView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(accountViewModel.account != nil, animated: animated)
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
        regularView?.isVisible = viewModel.account != nil
        accountAddressLabel.text = viewModel.account?.address
        transactionListController?.viewModel.account = viewModel.account
        navigationController?.setNavigationBarHidden(viewModel.account != nil, animated: true)

        UIView.animate(withDuration: 0.250) {
            self.view.layoutSubviews()
        }
    }
}
