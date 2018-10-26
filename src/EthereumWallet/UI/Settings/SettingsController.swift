//
//  SettingsController.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 22/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import UIKit
import JetLib

typealias SettingsSection = (header: String?, content: [Setting], footer: String?)

protocol Setting {

    var name: String { get }

    var accessory: UITableViewCell.AccessoryType { get }

    func didSelect()

    func canSelect() -> Bool
}

class SettingsViewModel: ViewModel {

    override init() {
        settings = [
            (header: "NETWORK", content: [], footer: ""),
            (header: "CHOOSE A NETWORK", content: [], footer: ""),
        ]
    }

    weak var view: SettingsController?

    var current: Network! {
        didSet {
            if current != Network.current {
                Network.selectNetwork(network: current)
            }

            var newSettings = settings
            newSettings[0].content = [NetworkSetting(current, self, selected: true)]
            newSettings[1].content = Network.all.filter{ $0 != Network.current }.map { NetworkSetting($0, self) }
            settings = newSettings
        }
    }

    var settings: [SettingsSection] {
        didSet {
            view?.reload()
        }
    }

    override func loadData() -> NotifyCompletion {
        current = Network.current
        return super.loadData()
    }
}

class NetworkSetting: Setting {

    private let selected: Bool
    private let network: Network

    private weak var viewModel: SettingsViewModel?

    init(_ network: Network, _ viewModel: SettingsViewModel, selected: Bool = false) {
        self.network = network
        self.selected = selected
        self.viewModel = viewModel
    }

    var accessory: UITableViewCell.AccessoryType {
        return selected ? .checkmark : .none
    }

    var name: String {
        return network.networkName
    }

    func didSelect() {
        viewModel?.current = network
    }

    func canSelect() -> Bool {
        return !selected
    }
}

class SettingsController: UITableViewController {

    lazy var viewModel: SettingsViewModel = container.resolve()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.view = self
        add(viewModel)
        tableView.register(SettingCell.self, forCellReuseIdentifier: SettingCell.cellId)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.settings.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.settings[section].content.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let setting = viewModel.settings[indexPath.section].content[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingCell.cellId, for: indexPath) as! SettingCell
        cell.setting = setting
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.settings[section].header
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return viewModel.settings[section].footer
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        (tableView.cellForRow(at: indexPath) as? SettingCell)?.setting.didSelect()
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return (tableView.cellForRow(at: indexPath) as? SettingCell)?.setting.canSelect() != false
    }
}

extension SettingsController {

    func reload() {
        tableView.reloadData()
    }
}

class SettingCell: UITableViewCell {

    static let cellId = "settingCell"

    var setting: Setting! {
        didSet {
            textLabel?.text = setting.name
            accessoryType = setting.accessory
        }
    }
}


