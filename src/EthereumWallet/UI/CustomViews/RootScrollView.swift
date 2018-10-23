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

    var snapToOffsets: [CGFloat] = []

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

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        guard !snapToOffsets.isEmpty else {
            return
        }

        var prev: CGFloat = 0
        let target = targetContentOffset.pointee.y

        for level in snapToOffsets {
            if target < level {
                let mid = (level + prev) / 2
                targetContentOffset.pointee.y = target > mid ? level : prev
                break
            }

            prev = level
        }
    }
}
