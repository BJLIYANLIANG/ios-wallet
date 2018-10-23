//
//  AccountListController.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 23/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import UIKit
import JetLib

protocol SelectedAccountDelegate: class {

    func accountChanged(_ account: Account?)
}

class AccountListController: UITableViewController, MenuController {

    var presenter: ControllerPresenter?

    weak var delegate: SelectedAccountDelegate?

    lazy var viewModel: AccountListViewModel = container.resolve()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(AccountCell.self, forCellReuseIdentifier: "accountCell")

        viewModel.view = self
        add(viewModel)
    }
}

extension AccountListController {

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell") as! AccountCell
        cell.account = viewModel.accounts?[indexPath.row]
        cell.selectionStyle = .none
        cell.accessoryType = cell.account?.address == viewModel.selected?.address ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.accounts?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selected = viewModel.accounts?[indexPath.row]
        delegate?.accountChanged(viewModel.selected)
    }
}

extension AccountListController: AccountListView {

    func collectionChanged(_ viewModel: AccountListViewModel) {
        tableView.reloadData()
    }

    func selectedChanged(_ viewModel: AccountListViewModel) {
        tableView.reloadData()
    }
}

class AccountCell: UITableViewCell {

    var account: Account? {
        didSet {
            textLabel?.text = account?.address
        }
    }
}
