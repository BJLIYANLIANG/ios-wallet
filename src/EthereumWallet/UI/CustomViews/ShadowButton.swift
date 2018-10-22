//
//  ShadowButton.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 22/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import UIKit


@IBDesignable
class ShadowButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var shadowColor: UIColor = UIColor.clear {
        didSet {
            layer.shadowColor = shadowColor.cgColor
        }
    }

    @IBInspectable var shadowOpacity: Float = 0 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }


    @IBInspectable var shadowRadius: CGFloat = 0 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }

    @IBInspectable var shadowOffset: CGSize = CGSize.zero {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }

    @IBInspectable var shadowOpacityPressed: Float = 0

    @IBInspectable var shadowRadiusPressed: CGFloat = 0

    @IBInspectable var shadowColorPressed: UIColor = UIColor.clear

    @IBInspectable var shadowOffsetPressed: CGSize = CGSize.zero

    override func layoutSubviews() {
        super.layoutSubviews()

        if let imageView = subviews.first(where: {$0 is UIImageView}) as? UIImageView {
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = cornerRadius
            imageView.layer.masksToBounds = true
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        layer.shadowColor = shadowColorPressed.cgColor
        layer.shadowOpacity = shadowOpacityPressed
        layer.shadowRadius = shadowRadiusPressed
        layer.shadowOffset = shadowOffsetPressed

        setNeedsDisplay()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        layer.shadowOffset = shadowOffset

        setNeedsDisplay()
    }
}
