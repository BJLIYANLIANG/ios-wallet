//
//  TransactionListController.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 12/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import UIKit
import JetLib

class TransactionListController: UITableViewController {

    lazy var viewModel: TransactionListViewModel = container.resolve()

    weak var noTransactionsView: UIView?

    var snapToOffsets: [CGFloat] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        add(viewModel)
        viewModel.view = self
    }
}

extension TransactionListController {

    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
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

extension TransactionListController {

    func reloadTransactions() {
        tableView.reloadData()
        noTransactionsView?.isVisible = viewModel.transactions?.isEmpty == true
    }
}

extension TransactionListController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.transactions?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell") as! TrasactionListCell
        cell.transaction = viewModel.transactions![indexPath.row]
        cell.isSelected = tableView.indexPathsForSelectedRows?.contains(indexPath) == true
        return cell
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.indexPathsForSelectedRows?.contains(indexPath) == true
            ? TrasactionListCell.expandedHeight
            : TrasactionListCell.collapsedHeight
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.indexPathsForSelectedRows?.contains(indexPath) == true
            ? TrasactionListCell.expandedHeight
            : TrasactionListCell.collapsedHeight
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}
