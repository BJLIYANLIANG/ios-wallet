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
        attach(viewModel)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
}


extension TransactionListController {

    func reloadTransactions() {
        tableView.reloadData()
        tableView.setContentOffset(CGPoint.zero, animated: false)
    }
}

extension TransactionListController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.transactions?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = viewModel.transactions![indexPath.row].hash
        return cell
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
