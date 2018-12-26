//
//  KeyboardObserver.swift
//  ContainerScrollViewController
//
//  Created by Drew Olbrich on 12/25/18.
//  Copyright © 2018 Drew Olbrich. All rights reserved.
//

import UIKit

/// An object that responds to changes in the keyboard's visibility.
///
/// When the keyboard is presented or dismissed, or when the size of the keyboard
/// changes, `KeyboardObserver` compensates by adjusting the
/// `ContainerScrollViewController` `additionalSafeAreaInsets` and
/// `embeddedViewHeightConstraint` properties.
class KeyboardObserver {

    // See https://developer.apple.com/library/archive/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html#//apple_ref/doc/uid/TP40009542-CH5-SW3

    private weak var containerScrollViewController: ContainerScrollViewController?

    private lazy var keyboardAdjustmentFilter = BottomInsetFilter(delegate: self)

    init(containerScrollViewController: ContainerScrollViewController) {
        self.containerScrollViewController = containerScrollViewController
        addObservers()
    }

    deinit {
        removeObservers()
    }

    private func addObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(updateForKeyboardVisibility), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(updateForKeyboardVisibility), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func removeObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    /// Updates the view controller to compensate for the appearance or disappearance of
    /// the keyboard.
    @objc private func updateForKeyboardVisibility(notification: Notification) {
        suppressTextFieldTextAnimation()

        switch notification.name {
        case UIResponder.keyboardWillHideNotification:
            setFilteredBottomInset(0)
        case UIResponder.keyboardWillShowNotification:
            if let bottomInset = bottomInsetFromKeyboardIntersectionFrameInScrollView(from: notification) {
                setFilteredBottomInset(bottomInset)
            }
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

    /// Suppresses unwanted text field text animation.
    ///
    /// If the user taps on a sequence of text fields, we may see unwanted animation in
    /// the position of the text within the text fields. This method suppresses this
    /// behavior by calling `layoutIfNeeded` within a `performWithoutAnimation` closure.
    private func suppressTextFieldTextAnimation() {
        guard let containerScrollViewController = containerScrollViewController else {
            return
        }

        UIView.performWithoutAnimation {
            containerScrollViewController.embeddedViewController?.view.layoutIfNeeded()
        }
    }


    // Returns the height of portion of the keyboard's frame that overlaps the scroll
    // view. This method correctly handles the case where the scroll view doesn't cover
    // the entire screen.
    private func bottomInsetFromKeyboardIntersectionFrameInScrollView(from notification: Notification) -> CGFloat? {
        guard let userInfo = notification.userInfo,
            let keyboardFrameEndUserInfoValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let containerScrollViewController = containerScrollViewController else {
            return nil
        }

        let scrollView = containerScrollViewController.scrollView

        guard let window = scrollView.window else {
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

        // The frame of the scroll view in the window's coordinate space.
        let scrollViewFrameInWindow = window.convert(scrollView.frame, from: scrollView.superview)

        let keyboardIntersectionFrameInWindow = scrollViewFrameInWindow.intersection(keyboardWindowEndFrame)

        let overlappingKeyboardFrame = window.convert(keyboardIntersectionFrameInWindow, to: scrollView.superview)

        let overlappingKeyboardHeight = overlappingKeyboardFrame.height

        let safeAreaBottomInset = containerScrollViewController.scrollView.safeAreaInsets.bottom
        let additionalSafeAreaBottomInset = containerScrollViewController.additionalSafeAreaInsets.bottom

        let bottomInset = max(0, overlappingKeyboardHeight - (safeAreaBottomInset - additionalSafeAreaBottomInset))

        return bottomInset
    }
}

extension KeyboardObserver: BottomInsetFilterDelegate {

    func keyboardAdjustmentFilter(_ keyboardAdjustmentFilter: BottomInsetFilter, didChangeBottomInset bottomInset: CGFloat) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: {
            self.setBottomInset(bottomInset)
            self.containerScrollViewController?.view.layoutIfNeeded()
        }, completion: nil)
    }

}
