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

    private lazy var keyboardAdjustmentFilter = KeyboardFrameFilter(delegate: self)

    // The duration of the animation of a change to the view's bottom inset.
    private let bottomInsetAnimationDuration: TimeInterval = 0.5

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

        guard let keyboardFrame = self.keyboardFrame(from: notification) else {
            return
        }

        setFilteredKeyboardFrame(keyboardFrame)
    }

    /// Suppresses unwanted text field text animation.
    ///
    /// If the user taps on a sequence of text fields, we may see unwanted animation in
    /// the position of the text within the text fields. This method suppresses this
    /// behavior by calling `layoutIfNeeded` within a `performWithoutAnimation` closure.
    ///
    /// We suspect that UIKit posts `UIResponder` keyboard notifications after updating
    /// text fields within animation blocks.
    private func suppressTextFieldTextAnimation() {
        guard let containerScrollViewController = containerScrollViewController else {
            return
        }

        UIView.performWithoutAnimation {
            containerScrollViewController.embeddedViewController?.view.layoutIfNeeded()
        }
    }

    /// Returns the keyboard's frame, given a notification.
    ///
    /// - Parameter notification: The `UIResponder` keyboard notification.
    /// - Returns: The keyboard's frame.
    private func keyboardFrame(from notification: Notification) -> CGRect? {
        guard let userInfo = notification.userInfo,
            let keyboardFrameEndUserInfoValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let window = containerScrollViewController?.view.window else {
                return nil
        }

        let keyboardWindowEndFrame = keyboardFrameEndUserInfoValue.cgRectValue

        // From https://developer.apple.com/library/archive/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html#//apple_ref/doc/uid/TP40009542-CH5-SW3
        // "Note: The rectangle contained in the UIKeyboardFrameBeginUserInfoKey and
        // UIKeyboardFrameEndUserInfoKey properties of the userInfo dictionary should be
        // used only for the size information it contains. Do not use the origin of the
        // rectangle (which is always {0.0, 0.0}) in rectangle-intersection operations.
        // Because the keyboard is animated into position, the actual bounding rectangle of
        // the keyboard changes over time."

        switch notification.name {
        case UIResponder.keyboardWillHideNotification:
            return CGRect(x: 0, y: window.bounds.height, width: keyboardWindowEndFrame.size.width, height: 0)
        case UIResponder.keyboardWillShowNotification:
            return CGRect(x: 0, y: window.bounds.height - keyboardWindowEndFrame.size.height, width: keyboardWindowEndFrame.size.width, height: keyboardWindowEndFrame.size.height)
        default:
            assertionFailure("Unexpected notification type")
            return nil
        }
    }

    /// Sets the keyboard frame, filtered over time by `KeyboardFrameFilter`.
    ///
    /// - Parameter keyboardFrame: The new keyboard frame value to assign.
    private func setFilteredKeyboardFrame(_ keyboardFrame: CGRect?) {
        keyboardAdjustmentFilter.keyboardFrame = keyboardFrame

        // Continues in keyboardAdjustmentFilter(_:didChangeKeyboardFrame:)...
    }

    /// Returns the height of portion of the keyboard's frame that overlaps
    /// ContainerScrollViewController's view.
    ///
    /// This method correctly handles the case where the view doesn't cover the entire
    /// screen.
    ///
    /// - Parameter notification: The keyboard notification that provides the keyboard's
    /// frame.
    /// - Returns: The height of portion of the keyboard's frame that overlaps the view.
    private func bottomInset(from keyboardFrame: CGRect) -> CGFloat? {
        guard let containerScrollViewController = containerScrollViewController,
            let view = containerScrollViewController.view,
            let window = view.window else {
            return nil
        }

        // The frame of the view in the window's coordinate space.
        let viewFrameInWindow = window.convert(view.frame, from: view.superview)

        // The intersection of the keyboard's frame with the frame of the view in the
        // window's coordinate space.
        let keyboardViewIntersectionFrameInWindow = viewFrameInWindow.intersection(keyboardFrame)

        // The intersection of the keyboard's frame with the frame of the view in the
        // view's coordinate space.
        let keyboardViewIntersectionFrameInView = window.convert(keyboardViewIntersectionFrameInWindow, to: view)

        // The height of the region of the keyboard that overlaps the view.
        let overlappingKeyboardHeight = keyboardViewIntersectionFrameInView.height

        // The view's safe area bottom inset.
        let safeAreaBottomInset = containerScrollViewController.view.safeAreaInsets.bottom

        // The view's additional safe area bottom inset.
        let additionalSafeAreaBottomInset = containerScrollViewController.additionalSafeAreaInsets.bottom

        let bottomInset = max(0, overlappingKeyboardHeight - (safeAreaBottomInset - additionalSafeAreaBottomInset))

        return bottomInset
    }

    private func setBottomInset(_ bottomInset: CGFloat) {
        guard let containerScrollViewController = containerScrollViewController,
            let embeddedViewHeightConstraint = containerScrollViewController.embeddedViewHeightConstraint else {
                return
        }

        switch containerScrollViewController.keyboardAdjustmentBehavior {
        case .none:
            return
        case .adjustScrollView:
            containerScrollViewController.additionalSafeAreaInsets.bottom = bottomInset
            embeddedViewHeightConstraint.constant = bottomInset
        case .adjustScrollViewAndEmbeddedView:
            containerScrollViewController.additionalSafeAreaInsets.bottom = bottomInset
        }
    }

}

extension KeyboardObserver: KeyboardFrameFilterDelegate {

    func keyboardAdjustmentFilter(_ keyboardAdjustmentFilter: KeyboardFrameFilter, didChangeKeyboardFrame keyboardFrame: CGRect?) {
        UIView.animate(withDuration: bottomInsetAnimationDuration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: {
            guard let keyboardFrame = keyboardFrame,
                let bottomInset = self.bottomInset(from: keyboardFrame) else {
                    return
            }
            self.setBottomInset(bottomInset)
            self.containerScrollViewController?.view.layoutIfNeeded()
        }, completion: nil)
    }

}
