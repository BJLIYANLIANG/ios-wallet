//
//  BlurButton.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 17/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class RoundedButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        clipsToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2
    }
}
