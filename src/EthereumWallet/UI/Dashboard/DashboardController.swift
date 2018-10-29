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

    lazy var transactionViewModel: TransactionListViewModel = container.resolve()

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
    @IBOutlet weak var transactionTableView: UITableView!

    let refresher: UIRefreshControl = UIRefreshControl()

    var addAccountCountroller: AddAccountController? {
        return children.first(where: { $0 is AddAccountController }) as? AddAccountController
    }

    var snapToOffsets: [CGFloat] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        add(accountViewModel)
        add(transactionViewModel)

        transactionViewModel.view = self
        accountViewModel.view = self

        addAccountCountroller?.viewModel.onAccountAdded = { [weak self] in
            self?.accountViewModel.account = self?.accountViewModel.accountsRepo.selected
            self?.navigationController?.setNavigationBarHidden(true, animated: true)
            self?.showAlert(title: "Your wallet has been created!")
        }

        copyAddressButton.command = accountViewModel.copyAddressCommand

        sendButton.command = ActionCommand.pushScreen(self, sbName: "Transactions", controllerId: "sendTransaction")
        contractButton.command = ActionCommand.pushScreen(self, sbName: "Contracts", controllerId: "executeContract")
        settingButton.command = ActionCommand.pushScreen(self, sbName: "Settings", controllerId: "settings")

        refresher.addTarget(self, action: #selector(handleRefresher), for: .valueChanged)

        transactionTableView.insertSubview(refresher, at: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(accountViewModel.account != nil, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.snapToOffsets = [
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
        transactionViewModel.dataUpdateRequested(initiator: group)
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
        transactionViewModel.account = viewModel.account
    }
}

extension DashboardController: TransactionListView {

    func reloadTransactions() {
        transactionTableView.reloadData()
        noTransactionsView?.isVisible = transactionViewModel.transactions?.isEmpty == true
    }
}


extension DashboardController: UIScrollViewDelegate {


    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard !snapToOffsets.isEmpty else {
            return
        }

        var prev: CGFloat = 0
        let target = targetContentOffset.pointee.y

        for level in snapToOffsets {
            if target < level {
                let mid = (level + prev) / 2
                targetContentOffset.pointee.y = target > mid ? level : prev
                break
            }

            prev = level
        }
    }
}

extension DashboardController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactionViewModel.transactions?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell") as! TrasactionListCell
        cell.transaction = transactionViewModel.transactions![indexPath.row]
        cell.skipSelectionAnimation = true
        cell.isSelected = tableView.indexPathsForSelectedRows?.contains(indexPath) == true
        cell.skipSelectionAnimation = false
        return cell
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.indexPathsForSelectedRows?.contains(indexPath) == true
            ? TrasactionListCell.expandedHeight
            : TrasactionListCell.collapsedHeight
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.indexPathsForSelectedRows?.contains(indexPath) == true
            ? TrasactionListCell.expandedHeight
            : TrasactionListCell.collapsedHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}
