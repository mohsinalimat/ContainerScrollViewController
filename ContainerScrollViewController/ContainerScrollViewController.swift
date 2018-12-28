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
/// The view hierarchy looks like this:
/// 1. `view (containerScrollViewController.view)`
/// 2. `scrollView`
/// 3. `embeddedView (embeddedViewController.view)`
///
/// The view controller hierarchy looks like this:
/// 1. `containerScrollViewController`
/// 2. `embeddedViewController`
open class ContainerScrollViewController: UIViewController {

    /// Embeds a view controller within the scroll view.
    ///
    /// A container view controller relationship may be established using Interface
    /// Builder, in which case the embedded view will be added automatically.
    /// Optionally, this method may be called in `viewDidLoad` to manually embed a view
    /// controller's view in the scroll view.
    ///
    /// This method may only be called once.
    ///
    /// - Parameter embeddedViewController: The view controller to embed in the scroll view.
    public func embedViewController(_ embeddedViewController: UIViewController) {
        containerScrollViewEmbedder.embedViewController(embeddedViewController)
    }

    /// The view controller whose view is embedded within the container scroll view.
    public var embeddedViewController: UIViewController? {
        return containerScrollViewEmbedder.embeddedViewController
    }

    /// The scroll view within which another view will be embedded.
    public var scrollView: UIScrollView {
        return containerScrollViewEmbedder.scrollView
    }

    /// If `true`, the embedded view should be resized to compensate for the portion of
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

}
