//
//  ContainerScrollViewController.swift
//  ContainerScrollViewController
//
//  Created by Drew Olbrich on 12/19/18.
//  Copyright © 2018 Drew Olbrich. All rights reserved.
//

import UIKit

/// A view controller that manages a scroll view, within which another view
/// controller's view is embedded. The scroll view's content size is adjusted to
/// reflect the embedded view's Auto Layout constraints.
///
/// This class is implemented in terms of `ContainerScrollViewEmbedder`, which may
/// be used directly if its scroll view embedding functionality is required in an
/// existing class that cannot inherit from `ContainerScrollViewController`.
///
/// The resulting view hierarchy looks like this:
///
///     view (embeddingViewController.view)
///       scrollView
///         embeddedView (embeddedViewController.view)
///
/// The view controller hierarchy looks like this:
///
///     containerScrollViewController
///         embeddedViewController
open class ContainerScrollViewController: UIViewController {

    /// The view controller whose view is embedded within the container scroll view.
    public var embeddedViewController: UIViewController? {
        return containerScrollViewEmbedder.embeddedViewController
    }

    /// The scroll view within which a view will be embedded.
    public var scrollView: UIScrollView {
        return containerScrollViewEmbedder.scrollView
    }

    /// If `true`, the embedded view will be resized to compensate for the portion of
    /// the view occupied by the keyboard, if possible. The default value is `false`.
    public var shouldResizeEmbeddedViewForKeyboard: Bool {
        set {
            containerScrollViewEmbedder.shouldResizeEmbeddedViewForKeyboard = newValue
        }
        get {
            return containerScrollViewEmbedder.shouldResizeEmbeddedViewForKeyboard
        }
    }

    /// The behavior for adjusting the view when the keyboard is presented. The default
    /// value of this property is `.adjustAdditionalSafeAreaInsets`.
    public var keyboardAdjustmentBehavior: ContainerScrollViewEmbedder.KeyboardAdjustmentBehavior {
        set {
            containerScrollViewEmbedder.keyboardAdjustmentBehavior = newValue
        }
        get {
            return containerScrollViewEmbedder.keyboardAdjustmentBehavior
        }
    }

    /// The margin applied to text fields when the scroll view is automatically scrolled
    /// to make the first responder text field visible. The default value is 0, which
    /// matches the UIKit default behavior.
    public var scrollToVisibleMargin: CGFloat {
        set {
            containerScrollViewEmbedder.scrollToVisibleMargin = newValue
        }
        get {
            return containerScrollViewEmbedder.scrollToVisibleMargin
        }
    }

    /// An object that manages embedding a view controller within a scroll view.
    private lazy var containerScrollViewEmbedder = ContainerScrollViewEmbedder(embeddingViewController: self)

    // If `viewDidLoad` is defined in a subclass of `ContainerScrollViewController`, it
    // must call `super.viewDidLoad`.
    open override func viewDidLoad() {
        containerScrollViewEmbedder.viewDidLoad()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        assert(containerScrollViewEmbedder.embeddedViewController != nil, "Either embedViewController must be called in viewDidLoad, or a container view controller relationship must be established in Interface Builder, in which case prepare(for:sender:), if overridden, must call super.prepare(for:sender:)")
    }

    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        containerScrollViewEmbedder.viewWillTransition(to: size, with: coordinator)
    }

    // If `prepare(for:sender:)` is defined in a subclass of
    // `ContainerScrollViewController`, it must call `super.prepare(for:sender:)`.
    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        containerScrollViewEmbedder.prepare(for: segue, sender: sender)
    }

    /// Embeds a view controller within the scroll view.
    ///
    /// A container view controller relationship may be established using Interface
    /// Builder, in which case the embedded view will be added automatically.
    /// Optionally, `embedViewController` may be called in `viewDidLoad` to manually
    /// embed a view controller's view in the scroll view.
    ///
    /// This method may only be called once.
    ///
    /// - Parameter embeddedViewController: The view controller to embed in the scroll view.
    public func embedViewController(_ embeddedViewController: UIViewController) {
        containerScrollViewEmbedder.embedViewController(embeddedViewController)
    }

    /// Scrolls the view to make the first responder text field visible.
    ///
    /// - Parameters:
    ///   - animated: If `true`, the scrolling is animated.
    ///   - margin: An optional margin to apply to the text field. If left unspecified,
    ///   `scrollToVisibleMargin` is used.
    public func scrollFirstResponderTextFieldToVisible(animated: Bool, margin: CGFloat? = nil) {
        containerScrollViewEmbedder.scrollFirstResponderTextFieldToVisible(animated: animated, margin: margin)
    }

    /// Scrolls the view to make the specified view visible.
    ///
    /// - Parameters:
    ///   - view: The view to make visible.
    ///   - animated: If `true`, the scrolling is animated.
    ///   - margin: An optional margin to apply to the view. If left unspecified,
    ///   `scrollToVisibleMargin` is used.
    public func scrollViewToVisible(_ view: UIView, animated: Bool, margin: CGFloat? = nil) {
        containerScrollViewEmbedder.scrollViewToVisible(view, animated: animated, margin: margin)
    }

    /// Scrolls the view to make a rect visible.
    ///
    /// Unlike `UIScrollView.scrollRectToVisible`, this method works correctly even if
    /// `keyboardAdjustmentBehavior` is set to `.adjustScrollViewContentSize`.
    ///
    /// - Parameters:
    ///   - rect: The rect to make visible.
    ///   - animated: If `true`, the scrolling is animated.
    ///   - margin: An optional margin to apply to `rect`. If left unspecified,
    ///   `scrollToVisibleMargin` is used.
    public func scrollRectToVisible(_ rect: CGRect, animated: Bool, margin: CGFloat? = nil) {
        containerScrollViewEmbedder.scrollRectToVisible(rect, animated: animated, margin: margin)
    }

}
