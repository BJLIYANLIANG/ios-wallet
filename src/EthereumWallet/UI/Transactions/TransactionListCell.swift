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

    static let collapsedHeight: CGFloat = 106
    static let expandedHeight: CGFloat = UITableView.automaticDimension

    @IBOutlet weak var directionIcon: UIImageView!
    @IBOutlet weak var directionLabel: UILabel!

    @IBOutlet weak var valueLable: UILabel!

    @IBOutlet weak var hashLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    @IBOutlet weak var arrowImage: UIImageView!

    @IBOutlet var stackConstraint: NSLayoutConstraint!

    @IBOutlet weak var compactAddress: UILabel?

    var transaction: Transaction? {
        didSet {
            switch transaction?.direction {
            case .income(let account)?:
                directionIcon.image = #imageLiteral(resourceName: "in-label")
                directionLabel.text = account
                compactAddress?.text = account
            case .outcome(let account)?:
                directionIcon.image = #imageLiteral(resourceName: "out-label")
                directionLabel.text = account
                compactAddress?.text = account
            default:
                directionIcon.image = nil
                directionLabel.text = "-"
                compactAddress?.text = "-"
            }

            valueLable.text = transaction?.value.description
            hashLabel.text = transaction?.hash
            dateLabel.text = transaction?.timeStamp.trasactionDateTime
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        stackConstraint.isActive = selected

        UIView.animate(withDuration: 0.250) {
            self.compactAddress?.isHidden = selected
            self.arrowImage.image = selected ? #imageLiteral(resourceName: "arrow-up") :#imageLiteral(resourceName: "arrow-down")
            self.layoutSubviews()
        }
    }
}
