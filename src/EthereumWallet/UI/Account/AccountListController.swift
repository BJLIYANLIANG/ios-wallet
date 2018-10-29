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
        viewModel.view = self
        add(viewModel)
        tableView.backgroundColor = UIColor.white
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

extension AccountListController {

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AccountCell.cellId) as! AccountCell
        cell.account = viewModel.accounts?[indexPath.row]
        cell.selectionStyle = .none
        cell.selectionImage.isVisible = cell.account?.address == viewModel.selected?.address
        cell.parent = self
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.accounts?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selected = viewModel.accounts?[indexPath.row]
        delegate?.accountChanged(viewModel.selected)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        viewModel.delete(account: (tableView.cellForRow(at: indexPath) as? AccountCell)?.account)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return viewModel.canDelete((tableView.cellForRow(at: indexPath) as? AccountCell)?.account)
    }
}

extension AccountListController: AccountListView {

    func collectionChanged(_ viewModel: AccountListViewModel) {
        tableView.reloadData()
    }

    func selectedChanged(_ viewModel: AccountListViewModel) {
        tableView.reloadData()
        delegate?.accountChanged(viewModel.selected)
    }
}

class AccountCell: UITableViewCell {

    static let cellId = "accountListCell"

    weak var parent: UIViewController?

    @IBOutlet weak var selectionImage: UIImageView!
    @IBOutlet weak var showDetailsButton: UIButton!
    @IBOutlet weak var accontAddressLabel: UILabel!

    var account: Account? {
        didSet {
            accontAddressLabel?.text = account?.address
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        showDetailsButton.command = ActionCommand(self) {
            let sb = UIStoryboard(name: "Account", bundle: nil)
            let controller = sb.instantiateViewController(withIdentifier: "accountDetails") as! AccountDetailsController
            controller.account = $0.account
            $0.parent?.navigationController?.pushViewController(controller, animated: true)
        }
    }
}
