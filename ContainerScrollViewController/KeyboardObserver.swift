//
//  KeyboardObserver.swift
//  ContainerScrollViewController
//
//  Created by Drew Olbrich on 12/25/18.
//  Copyright © 2018 Drew Olbrich. All rights reserved.
//

import UIKit

class KeyboardObserver: NSObject {

    // See https://developer.apple.com/library/archive/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html#//apple_ref/doc/uid/TP40009542-CH5-SW3

    private weak var containerScrollViewController: ContainerScrollViewController?

    private lazy var keyboardAdjustmentFilter = KeyboardAdjustmentFilter(delegate: self)

    init(containerScrollViewController: ContainerScrollViewController) {
        self.containerScrollViewController = containerScrollViewController

        super.init()

        addObservers()
    }

    deinit {
        removeObservers()
    }

    private func addObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(updateForKeyboardVisibility), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(updateForKeyboardVisibility), name: UIResponder.keyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(updateForKeyboardVisibility), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(updateForKeyboardVisibility), name: UIResponder.keyboardDidHideNotification, object: nil)
    }

    private func removeObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
    }

    /// Updates the view controller to compensate for the appearance or disappearance of
    /// the keyboard.
    @objc private func updateForKeyboardVisibility(notification: Notification) {
        #if false
        switch notification.name {
        case UIResponder.keyboardWillHideNotification:
            NSLog("keyboardWillHideNotification")
        case UIResponder.keyboardDidHideNotification:
            NSLog("keyboardDidHideNotification")
        case UIResponder.keyboardWillShowNotification:
            NSLog("keyboardWillShowNotification")
        case UIResponder.keyboardDidShowNotification:
            NSLog("keyboardDidShowNotification")
        default:
            break
        }
        if let userInfo = notification.userInfo,
            let animationDuration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue {
            NSLog("    animationDuration = \(animationDuration)")
        }
        #endif

        guard let containerScrollViewController = containerScrollViewController else {
            return
        }

        // If we don't do this, then we may see unwanted animation of UITextField text
        // as the focus moves between text fields.
        UIView.performWithoutAnimation {
            containerScrollViewController.embeddedViewController?.view.layoutIfNeeded()
        }

        switch notification.name {
        case UIResponder.keyboardWillHideNotification:
            setFilteredBottomInset(0)
        case UIResponder.keyboardWillShowNotification:
            guard let keyboardIntersectionFrameInScrollView = keyboardIntersectionFrameInScrollView(from: notification) else {
                return
            }
            let keyboardHeight = keyboardIntersectionFrameInScrollView.height
            let safeAreaBottomInset = containerScrollViewController.scrollView.safeAreaInsets.bottom
            let additionalSafeAreaBottomInset = containerScrollViewController.additionalSafeAreaInsets.bottom
            let bottomInset = max(0, keyboardHeight - (safeAreaBottomInset - additionalSafeAreaBottomInset))
            setFilteredBottomInset(bottomInset)
        default:
            // Do nothing.
            break
        }
    }

    private func setFilteredBottomInset(_ bottomInset: CGFloat) {
        keyboardAdjustmentFilter.bottomInset = bottomInset

        // Continues in keyboardAdjustmentFilter(_:didChangeBottomInset:)...
    }

    private func setBottomInset(_ bottomInset: CGFloat) {
        guard let keyboardAdjustmentBehavior = containerScrollViewController?.keyboardAdjustmentBehavior,
            let containerScrollViewController = containerScrollViewController,
            let embeddedViewHeightConstraint = containerScrollViewController.embeddedViewHeightConstraint else {
            return
        }

        switch keyboardAdjustmentBehavior {
        case .none:
            return
        case .adjustScrollView:
            containerScrollViewController.additionalSafeAreaInsets.bottom = bottomInset
            embeddedViewHeightConstraint.constant = bottomInset
        case .adjustScrollViewAndEmbeddedView:
            containerScrollViewController.additionalSafeAreaInsets.bottom = bottomInset
        }
    }

    // Computes the intersection of the keyboard's frame with the scroll view in the
    // scroll view's coordinate space. This correctly handles the case where the scroll
    // view doesn't cover the entire screen.
    private func keyboardIntersectionFrameInScrollView(from notification: Notification) -> CGRect? {
        guard let userInfo = notification.userInfo,
            let keyboardFrameEndUserInfoValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
                return nil
        }

        guard let scrollView = containerScrollViewController?.scrollView, let window = scrollView.window else {
            return nil
        }

        var keyboardWindowEndFrame = keyboardFrameEndUserInfoValue.cgRectValue

        // From https://developer.apple.com/library/archive/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html#//apple_ref/doc/uid/TP40009542-CH5-SW3
        // Note: The rectangle contained in the UIKeyboardFrameBeginUserInfoKey and
        // UIKeyboardFrameEndUserInfoKey properties of the userInfo dictionary should be
        // used only for the size information it contains. Do not use the origin of the
        // rectangle (which is always {0.0, 0.0}) in rectangle-intersection operations.
        // Because the keyboard is animated into position, the actual bounding rectangle of
        // the keyboard changes over time.
        keyboardWindowEndFrame = CGRect(x: 0, y: window.bounds.height - keyboardWindowEndFrame.size.height, width: keyboardWindowEndFrame.size.width, height: keyboardWindowEndFrame.size.height)

        let scrollViewFrameInWindow = window.convert(scrollView.frame, from: scrollView.superview)
        let keyboardIntersectionFrameInWindow = scrollViewFrameInWindow.intersection(keyboardWindowEndFrame)

        return window.convert(keyboardIntersectionFrameInWindow, to: scrollView.superview)
    }
}

extension KeyboardObserver: KeyboardAdjustmentFilterDelegate {

    func keyboardAdjustmentFilter(_ keyboardAdjustmentFilter: KeyboardAdjustmentFilter, didChangeBottomInset bottomInset: CGFloat) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: {
            self.setBottomInset(bottomInset)
            self.containerScrollViewController?.view.layoutIfNeeded()
        }, completion: nil)
    }

}
