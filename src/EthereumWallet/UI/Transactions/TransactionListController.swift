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


    override func viewDidLoad() {
        super.viewDidLoad()
        add(viewModel)
        viewModel.view = self
    }
}

extension TransactionListController {

    func reloadTransactions() {
        tableView.reloadData()
    }
}

extension TransactionListController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.transactions?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell") as! TrasactionListCell
        cell.transaction = viewModel.transactions![indexPath.row]
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
