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
class RoundedBlurButton: UIButton {

    override init(frame: CGRect) {
        effect = UIVisualEffectView(effect: UIBlurEffect(style: .light))

        super.init(frame: frame)

        clipsToBounds = true
        insertEeffect(effect)
    }

    required init?(coder aDecoder: NSCoder) {
        effect = UIVisualEffectView(effect: UIBlurEffect(style: .light))

        super.init(coder: aDecoder)


        clipsToBounds = true
        insertEeffect(effect)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        effect?.frame = self.bounds
        layer.cornerRadius = bounds.width / 2
    }

    var effect: UIVisualEffectView! {
        didSet {
            oldValue?.removeFromSuperview()
            insertEeffect(effect)
        }
    }

    fileprivate func insertEeffect(_ effect: UIVisualEffectView?) {
        guard let effect = effect else {
            return
        }

        effect.isUserInteractionEnabled = false

        if let imageView = imageView {
            insertSubview(effect, aboveSubview: imageView)
        } else {
            insertSubview(effect, at: 0)
        }
    }
}
