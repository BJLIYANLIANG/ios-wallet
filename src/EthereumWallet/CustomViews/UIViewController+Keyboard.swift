//
//  UIViewController+Keyboard.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 24/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {

    private struct AssociatedKeys {
        static var scrollKeyboardOffset: UInt8 = 0
        static var scrollViewForKeyboard: UInt8 = 0
        static var isKeyboardListening: UInt8 = 0
    }

    private var scrollKeyboardOffset: CGFloat! {
        get { return (objc_getAssociatedObject(self, &AssociatedKeys.scrollKeyboardOffset) as? CGFloat) ?? 0 }
        set { return objc_setAssociatedObject(self, &AssociatedKeys.scrollKeyboardOffset, newValue, .OBJC_ASSOCIATION_COPY) }
    }

    private var scrollViewForKeyboard: UIScrollView? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.scrollViewForKeyboard) as? UIScrollView }
        set { return objc_setAssociatedObject(self, &AssociatedKeys.scrollViewForKeyboard, newValue, .OBJC_ASSOCIATION_ASSIGN) }
    }

    private var isKeyboardListening: Bool! {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.isKeyboardListening) as? Bool ?? false }
        set { return objc_setAssociatedObject(self, &AssociatedKeys.isKeyboardListening, newValue, .OBJC_ASSOCIATION_COPY) }
    }

    var rootViewController: UIViewController {
        var controller = self

        while controller.parent != nil {
            controller = controller.parent!
        }

        return controller
    }

    func find<T: UIViewController>() -> T? {
        loadViewIfNeeded()
        return children.first(where: { $0 is T }) as? T
    }

    func findAllChilds<T: UIViewController>() -> [T] {
        loadViewIfNeeded()
        return children.filter { $0 is T }.map { $0 as! T }
    }

    @discardableResult
    func hideKeyboardWhenTappedAround() -> UITapGestureRecognizer {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        return tap
    }

    func adjustKeyboardInsets(to scrollView: UIScrollView, with offset: CGFloat = 8) {
        scrollViewForKeyboard = scrollView
        scrollKeyboardOffset = offset

        handleKeyboardAppearance()
    }

    func handleKeyboardAppearance() {
        if !isKeyboardListening {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }

    @objc
    func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc
    final func keyboardWillShow(notification: NSNotification) {
        keyboardWillShowOverride(notification)

        var userInfo = notification.userInfo!
        var keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        defer {
            keyboardPostWillShow(keyboardFrame: keyboardFrame, scrollView: scrollViewForKeyboard)
        }

        guard let scrollView = self.scrollViewForKeyboard else {
            return
        }

        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 0
        var contentInset = scrollView.contentInset

        contentInset.bottom = max(keyboardFrame.size.height + scrollKeyboardOffset - tabBarHeight, 0)
        scrollView.contentInset = contentInset
    }

    @objc
    final func keyboardWillHide(notification: NSNotification) {
        keyboardWillHideOverride(notification)

        guard let scrollView = self.scrollViewForKeyboard else {
            return
        }

        scrollView.contentInset = UIEdgeInsets.zero
    }

    @objc
    func keyboardPostWillShow(keyboardFrame: CGRect, scrollView: UIScrollView?) {
    }

    @objc
    func keyboardWillShowOverride(_ notification: NSNotification) {
    }

    @objc
    func keyboardWillHideOverride(_ notification: NSNotification) {
    }
}
