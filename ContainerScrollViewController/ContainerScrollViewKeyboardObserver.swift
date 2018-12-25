//
//  ContainerScrollViewKeyboardObserver.swift
//  ContainerScrollViewController
//
//  Created by Drew Olbrich on 12/25/18.
//  Copyright © 2018 Drew Olbrich. All rights reserved.
//

import UIKit

class ContainerScrollViewKeyboardObserver: NSObject {

    // See https://developer.apple.com/library/archive/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html#//apple_ref/doc/uid/TP40009542-CH5-SW3

    private weak var containerScrollViewController: ContainerScrollViewController?

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
        #if true
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
        #endif

        guard let keyboardAdjustmentBehavior = containerScrollViewController?.keyboardAdjustmentBehavior else {
            return
        }

        switch keyboardAdjustmentBehavior {
        case .none:
            return
        case .adjustScrollView:
            adjustScrollView(notification: notification)
        case .adjustScrollViewAndEmbeddedView:
            adjustScrollViewAndEmbeddedView(notification: notification)
        }
    }

    private func adjustScrollView(notification: Notification) {
        guard let containerScrollViewController = containerScrollViewController, let embeddedViewHeightConstraint = containerScrollViewController.embeddedViewHeightConstraint else {
            return
        }

        switch notification.name {
        case UIResponder.keyboardWillHideNotification:
            if containerScrollViewController.additionalSafeAreaInsets.bottom != 0 {
                NSLog(">>> Setting bottom to 0")
                containerScrollViewController.additionalSafeAreaInsets.bottom = 0
                embeddedViewHeightConstraint.constant = 0
            }
        case UIResponder.keyboardWillShowNotification:
            guard let keyboardIntersectionFrameInScrollView = keyboardIntersectionFrameInScrollView(from: notification) else {
                return
            }
            let newBottomSafeAreaInset = keyboardIntersectionFrameInScrollView.height - (containerScrollViewController.scrollView.safeAreaInsets.bottom - containerScrollViewController.additionalSafeAreaInsets.bottom)
            if containerScrollViewController.additionalSafeAreaInsets.bottom != newBottomSafeAreaInset {
                NSLog(">>> Setting bottom to \(newBottomSafeAreaInset)")
                containerScrollViewController.additionalSafeAreaInsets.bottom = newBottomSafeAreaInset
                embeddedViewHeightConstraint.constant = newBottomSafeAreaInset
            }
        default:
            // Do nothing.
            break
        }
    }

    private func adjustScrollViewAndEmbeddedView(notification: Notification) {
        guard let containerScrollViewController = containerScrollViewController else {
            return
        }

        // If we don't do this, then we may see unwanted animation of UITextField text
        // as the focus moves between text fields.
        UIView.performWithoutAnimation {
            containerScrollViewController.scrollView.layoutIfNeeded()
        }

        switch notification.name {
        case UIResponder.keyboardWillHideNotification:
            if containerScrollViewController.additionalSafeAreaInsets.bottom != 0 {
                containerScrollViewController.additionalSafeAreaInsets.bottom = 0
                containerScrollViewController.scrollView.layoutIfNeeded()
            }
        case UIResponder.keyboardWillShowNotification:
            guard let keyboardIntersectionFrameInScrollView = keyboardIntersectionFrameInScrollView(from: notification) else {
                return
            }
            let newBottomSafeAreaInset = keyboardIntersectionFrameInScrollView.height - (containerScrollViewController.scrollView.safeAreaInsets.bottom - containerScrollViewController.additionalSafeAreaInsets.bottom)
            if containerScrollViewController.additionalSafeAreaInsets.bottom != newBottomSafeAreaInset {
                containerScrollViewController.additionalSafeAreaInsets.bottom = newBottomSafeAreaInset
                containerScrollViewController.view.layoutIfNeeded()
            }
        default:
            // Do nothing.
            break
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

        let keyboardWindowEndFrame = keyboardFrameEndUserInfoValue.cgRectValue
        let scrollViewFrameInWindow = window.convert(scrollView.frame, from: scrollView.superview)
        let keyboardIntersectionFrameInWindow = scrollViewFrameInWindow.intersection(keyboardWindowEndFrame)

        return window.convert(keyboardIntersectionFrameInWindow, to: scrollView.superview)
    }

}
