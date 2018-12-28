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
/// changes, `KeyboardObserver` compensates by calling
/// `ContainerScrollViewEmbedder.adjustViewForKeyboard(withBottomInset:)` method
/// after a short delay. See `KeyboardFrameFilter` for details.
class KeyboardObserver {

    // See https://developer.apple.com/library/archive/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html#//apple_ref/doc/uid/TP40009542-CH5-SW3

    private weak var containerScrollViewEmbedder: ContainerScrollViewEmbedder?

    private var embeddingViewController: UIViewController? {
        return containerScrollViewEmbedder?.embeddingViewController
    }

    private lazy var keyboardAdjustmentFilter = KeyboardFrameFilter(delegate: self)

    // The duration of the animation of the change to the container view's bottom inset.
    private let bottomInsetAnimationDuration: TimeInterval = 0.5

    init(containerScrollViewEmbedder: ContainerScrollViewEmbedder) {
        self.containerScrollViewEmbedder = containerScrollViewEmbedder
        addObservers()
    }

    deinit {
        removeObservers()
    }

    /// Suspends filtering of changes to the keyboard's frame.
    func suspend() {
        keyboardAdjustmentFilter.suspend()
    }

    /// Resumes filtering of changes to the keyboard's frame.
    func resume() {
        keyboardAdjustmentFilter.resume()
    }

    /// Immediately responds to pending keyboard frame changes.
    func flush() {
        keyboardAdjustmentFilter.flush()
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
    /// the keyboard or changes to the keyboard's size.
    @objc private func updateForKeyboardVisibility(notification: Notification) {
        guard let keyboardFrame = self.keyboardFrame(from: notification),
            let scrollView = containerScrollViewEmbedder?.scrollView else {
                return
        }

        suppressTextFieldTextAnimation()

        keyboardAdjustmentFilter.keyboardFrame = keyboardFrame

        // If the keyboard is being dismissed by way of a drag gesture and the embedded
        // view is resizable, respond to the change in the keyboard's frame immediately,
        // without the temporal filtering normally provided by KeyboardAdjustmentFilter, so
        // the animation of the scroll view's frame change is handled within UIKit's
        // animation block that wraps the keyboardWillHide notification. This results in
        // more pleasing animation. If we instead waited until KeyboardAdjustmentFilter's
        // timer fired, we'd see an awkward jump of the scroll view's contents as the
        // embedded view area was resized.
        if notification.name == UIResponder.keyboardWillHideNotification
            && containerScrollViewEmbedder?.shouldResizeEmbeddedViewForKeyboard == true
            && scrollView.keyboardDismissMode != .none
            && scrollView.isTracking {
            keyboardAdjustmentFilter.flush()
        }

        // Continues in keyboardAdjustmentFilter(_:didChangeKeyboardFrame:)...
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
        UIView.performWithoutAnimation {
            containerScrollViewEmbedder?.embeddedView?.layoutIfNeeded()
        }
    }

    /// Returns the keyboard's frame, given a notification.
    ///
    /// - Parameter notification: The `UIResponder` keyboard notification.
    /// - Returns: The keyboard's frame.
    private func keyboardFrame(from notification: Notification) -> CGRect? {
        guard let userInfo = notification.userInfo,
            let keyboardFrameEndUserInfoValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let window = embeddingViewController?.view.window else {
                return nil
        }

        let keyboardFrame = keyboardFrameEndUserInfoValue.cgRectValue

        // From https://developer.apple.com/library/archive/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html#//apple_ref/doc/uid/TP40009542-CH5-SW3
        // "Note: The rectangle contained in the UIKeyboardFrameBeginUserInfoKey and
        // UIKeyboardFrameEndUserInfoKey properties of the userInfo dictionary should be
        // used only for the size information it contains. Do not use the origin of the
        // rectangle (which is always {0.0, 0.0}) in rectangle-intersection operations.
        // Because the keyboard is animated into position, the actual bounding rectangle of
        // the keyboard changes over time."

        switch notification.name {
        case UIResponder.keyboardWillHideNotification:
            return CGRect(x: 0, y: window.bounds.height, width: keyboardFrame.size.width, height: 0)
        case UIResponder.keyboardWillShowNotification:
            return CGRect(x: 0, y: window.bounds.height - keyboardFrame.size.height, width: keyboardFrame.size.width, height: keyboardFrame.size.height)
        default:
            assertionFailure("Unexpected notification type")
            return nil
        }
    }

    /// Returns the height of portion of the keyboard's frame that overlaps the scroll
    /// view.
    ///
    /// This method correctly handles the case where the view doesn't cover the entire
    /// screen.
    ///
    /// - Parameter notification: The keyboard notification that provides the keyboard's
    /// frame.
    /// - Returns: The height of portion of the keyboard's frame that overlaps the view.
    private func bottomInset(from keyboardFrame: CGRect?) -> CGFloat? {
        guard let keyboardFrame = keyboardFrame,
            let embeddingViewController = embeddingViewController,
            let view = embeddingViewController.view,
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
        let safeAreaBottomInset = embeddingViewController.view.safeAreaInsets.bottom

        // The view's additional safe area bottom inset.
        let additionalSafeAreaBottomInset = embeddingViewController.additionalSafeAreaInsets.bottom

        // The height of area of the keyboard's frame that overlaps the view.
        return max(0, overlappingKeyboardHeight - (safeAreaBottomInset - additionalSafeAreaBottomInset))
    }

}

extension KeyboardObserver: KeyboardFrameFilterDelegate {

    func keyboardAdjustmentFilter(_ keyboardAdjustmentFilter: KeyboardFrameFilter, didChangeKeyboardFrame keyboardFrame: CGRect?) {
        guard let bottomInset = self.bottomInset(from: keyboardFrame) else {
            return
        }

        UIView.animate(withDuration: bottomInsetAnimationDuration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: {
            self.containerScrollViewEmbedder?.adjustViewForKeyboard(withBottomInset: bottomInset)
            self.embeddingViewController?.view.layoutIfNeeded()
        }, completion: nil)
    }

}
