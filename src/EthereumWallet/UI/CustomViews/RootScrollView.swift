//
//  RootScrollView.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 19/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import UIKit

class RootScrollView: UIScrollView, UIScrollViewDelegate {

    weak var nestedScrollView: UIScrollView? {
        didSet {
            oldValue?.isScrollEnabled = true
            nestedScrollView?.isScrollEnabled = false

            if nestedScrollView != nil {
                self.delegate = self
            } else {
                self.delegate = nil
            }
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let nested = nestedScrollView else {
            return
        }

        let maxRootOffset = contentSize.height - frame.height
        let maxNested = nested.contentSize.height - nested.frame.height
        let totalOffset = contentOffset.y + nested.contentOffset.y
        let nestedOffset = max(0, min(totalOffset - maxRootOffset, maxNested))

        nested.contentOffset.y = nestedOffset
        contentOffset.y = totalOffset - nestedOffset
    }
}
