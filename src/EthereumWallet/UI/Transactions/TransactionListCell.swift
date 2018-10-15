//
//  TransactionListCell.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 15/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import UIKit

class TrasactionListCell: UITableViewCell {

    static let collapsedHeight: CGFloat = 72
    static let expandedHeight: CGFloat = 130

    @IBOutlet weak var directionIcon: UIImageView!
    @IBOutlet weak var directionLabel: UILabel!

    @IBOutlet weak var valueLable: UILabel!

    @IBOutlet weak var expandedStack: UIStackView!
    @IBOutlet weak var hashLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    var transaction: Transaction? {
        didSet {
            switch transaction?.direction {
            case .income(let account)?:
                directionIcon.image = nil // TODO:
                directionLabel.text = account
            case .outcome(let account)?:
                directionIcon.image = nil // TODO:
                directionLabel.text = account
            default:
                directionIcon.image = nil // TODO:
                directionLabel.text = "-"
            }

            valueLable.text = transaction?.value
            hashLabel.text = transaction?.hash
            dateLabel.text = transaction?.timeStamp.description
        }
    }
}


