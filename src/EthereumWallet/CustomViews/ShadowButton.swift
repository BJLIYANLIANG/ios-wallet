//
//  ShadowButton.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 22/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import UIKit

class ShadowButton: UIButton {

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

    @IBInspectable var shadowOpacityPressed: Float = 0.8

    @IBInspectable var shadowRadiusPressed: CGFloat = 5

    @IBInspectable var shadowColorPressed: UIColor = UIColor.clear

    @IBInspectable var shadowOffsetPressed: CGSize = CGSize(width: -1, height: 2)

    @IBInspectable var backgroundColorPressed: UIColor? = nil {
        didSet {
            if let color = backgroundColorPressed  {
                setBackgroundImage(UIImage(color: color), for: .highlighted)
            }
        }
    }

    override var backgroundColor: UIColor? {
        didSet {
            if let color = backgroundColor  {
                setBackgroundImage(UIImage(color: color), for: .normal)
            } else {
                setBackgroundImage(nil, for: .normal)
            }
        }
    }

    override var isHighlighted: Bool {
        get { return super.isHighlighted }
        set {
            guard newValue != isHighlighted else {
                return
            }

            UIView.transition(with: self, duration: 0.250, options: [.allowAnimatedContent, .curveEaseInOut], animations: {
                super.isHighlighted = newValue
            }, completion: nil)

            CATransaction.begin()
            CATransaction.setAnimationDuration(0.250)
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut))

            if newValue {
                layer.shadowColor = shadowColorPressed.cgColor
                layer.shadowOpacity = shadowOpacityPressed
                layer.shadowRadius = shadowRadiusPressed
                layer.shadowOffset = shadowOffsetPressed
            } else {
                layer.shadowColor = shadowColor.cgColor
                layer.shadowOpacity = shadowOpacity
                layer.shadowRadius = shadowRadius
                layer.shadowOffset = shadowOffset
            }

            CATransaction.commit()
        }
    }

    override var frame: CGRect {
        didSet {
            if let imageView = subviews.first(where: {$0 is UIImageView}) as? UIImageView {
                imageView.clipsToBounds = true
                imageView.layer.cornerRadius = cornerRadius
                imageView.layer.masksToBounds = true
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if let imageView = subviews.first(where: {$0 is UIImageView}) as? UIImageView, imageView.layer.cornerRadius != cornerRadius {
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = cornerRadius
            imageView.layer.masksToBounds = true
        }
    }
}
