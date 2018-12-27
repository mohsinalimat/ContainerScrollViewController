//
//  ContainerScrollViewController.swift
//  ContainerScrollViewController
//
//  Created by Drew Olbrich on 12/19/18.
//  Copyright © 2018 Drew Olbrich. All rights reserved.
//

import UIKit

/// A view controller that manages a scroll view, within which another view
/// controller is embedded. The scroll view's content size is adjusted to reflect
/// the embedded view's Auto Layout constraints.
open class ContainerScrollViewController: UIViewController {

    /// The scroll view within which another view will be embedded.
    public let scrollView = UIScrollView()

    /// The view controller whose view is embedded within the container scroll view.
    public private(set) var embeddedViewController: UIViewController?

    /// The view embedded in the scroll view.
    public var embeddedView: UIView? {
        return embeddedViewController?.view
    }

    /// If `true`, the embedded view should be resized to compensate for the portion of
    /// the view occupied by the keyboard, if possible. The default value is `false`.
    public var shouldResizeEmbeddedViewForKeyboard = false

    /// The behavior for adjusting the view when the keyboard is presented.
    public enum KeyboardAdjustmentBehavior {
        /// Make no view adjustments when the keyboard is presented.
        case none
        /// Adjust the view controller's additional safe area insets. This is the default
        /// behavior.
        case adjustAdditionalSafeAreaInsets
        /// Adjust the scroll view's content size. This approach leaves the view
        /// controller's additional safe area insets untouched, but will result in
        /// misaligned scroll indicators when the left and right safe area insets are
        /// nonzero, for example in landscape orientation on iPhone X. This appears to be a
        /// side effect of setting the bottom scroll indicator inset to a nonzero value.
        case adjustScrollViewContentSize
    }

    /// The behavior for adjusting the view when the keyboard is presented. The default
    /// value of this property is `.adjustAdditionalSafeAreaInsets`.
    public var keyboardAdjustmentBehavior: KeyboardAdjustmentBehavior = .adjustAdditionalSafeAreaInsets

    /// This property is `true` if viewDidLoad has already been called.
    private var viewDidLoadWasCalled = false

    /// The embedded view's height constraint.
    private var embeddedViewMinimumHeightConstraint: NSLayoutConstraint?

    /// The scroll view's bottom anchor constraint.
    private var scrollViewBottomAnchorConstraint: NSLayoutConstraint?

    /// An object that responds to notifications posted by UIKit when the keyboard is
    /// presented or dismissed, and which adjusts the `ContainerScrollViewController`
    /// scroll view to compensate.
    private var keyboardObserver: KeyboardObserver?

    /// An object that modifies the scroll view's `alwaysBounceVertical` property to
    /// reflect the state of the presented keyboard. This ensures that when
    /// `keyboardDismissMode` is set to `.interactive` it will work as expected, even if
    /// the embedded view is short enough to not require scrolling.
    private lazy var scrollViewBounceController = ScrollViewBounceController(scrollView: scrollView)

    // Prepares for the container view embedding segue. If `prepare(for:sender:)` is
    // defined in a subclass of `ContainerScrollViewController`, it must call
    // `super.prepare(for:sender:)`.
    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        // We're assuming that if a segue is initiated before viewDidLoad is called,
        // it must be a container view embedding segue.
        if !viewDidLoadWasCalled {
            assert(segue.source == self)
            assert(embeddedViewController == nil)
            embeddedViewController = segue.destination
        }
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        viewDidLoadWasCalled = true

        keyboardObserver = KeyboardObserver(containerScrollViewController: self)

        // If we don't do this, and instead leave contentInsetAdjustmentBehavior at
        // .automatic (its default value), then in the case when a container view
        // controller is presented outside of the context of a navigation controller,
        // changes to the size of the embedded view will result in the embedded view's safe
        // area insets changing unpredictably.
        // We're choosing .always here instead of .never because unlike .never, the .always
        // behavior adjusts the scroll indicator insets, which is desirable, in particular
        // on iPhone X in landscape orientation with the keyboard presented.
        scrollView.contentInsetAdjustmentBehavior = .always

        assert(view.subviews.count <= 1, "The ContainerScrollViewController view is expected to have at most one subview embedded by Interface Builder")

        if embeddedViewController != nil {
            // An embedded view controller was specified in Interface Builder, in which case
            // prepare(for:sender:) was called before viewDidLoad.

            guard let embeddedView = embeddedViewController?.view else {
                assertionFailure("The embedded view controller's view is undefined")
                return
            }

            scrollView.addSubview(embeddedView)
            addScrollView()

            return
        }

        // At this point, it is expected that embedViewController will be called in
        // the ContainerScrollViewController subclass's viewDidLoad method.
    }

    /// Embeds a view controller within the scroll view. If a view a container view
    /// controller relationship is not established in Interface Builder, this method may
    /// be called in `viewDidLoad` to manually embed a view controller's view in the
    /// scroll view.
    ///
    /// This method may only be called once.
    ///
    /// - Parameter embeddedViewController: The view controller to embed in the scroll view.
    public func embedViewController(_ embeddedViewController: UIViewController) {
        assert(self.embeddedViewController == nil, "Only one view controller may be embedded in a ContainerScrollViewController")

        self.embeddedViewController = embeddedViewController

        guard let embeddedView = embeddedViewController.view else {
            assertionFailure("The embedded view controller's view is undefined")
            return
        }

        addChild(embeddedViewController)
        scrollView.addSubview(embeddedView)
        embeddedViewController.didMove(toParent: self)

        addScrollView()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        assert(embeddedViewController != nil, "Either embedViewController must be called in viewDidLoad, or a container view controller relationship must be established in Interface Builder, in which case prepare(for:sender:), if overridden, must call super.prepare(for:sender:)")
    }

    /// Adds the scroll view to the view hierarchy.
    private func addScrollView() {
        assert(scrollView.superview == nil)

        // Insert our scroll view between the container view and the embedded view.
        // Instead of this approach, we'd instead prefer to directly specify UIScrollView
        // as the container view's class in Interface Builder, but this results in the
        // following exception when the embed segue is performed:
        //     *** Terminating app due to uncaught exception 'NSInternalInconsistencyException',
        //     reason: 'There are unexpected subviews in the container view. Perhaps the embed
        //     segue has already fired once or a subview was added programmatically?'
        view.addSubview(scrollView)
        scrollView.frame = view.bounds
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        addEmbeddedViewConstraints()

        // Some UIViewController properties, like childViewControllerForStatusBarStyle, are
        // queried by UIKit before viewDidLoad is called. To handle the case where
        // childViewControllerForStatusBarStyle forwards the definition of these properties
        // to the newly embedded view controller, we call the following methods to ensure
        // that the correct state is presented to the user when the view is presented.
        setNeedsStatusBarAppearanceUpdate()
        setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
        setNeedsUpdateOfHomeIndicatorAutoHidden()
    }

    /// Constrains the embedded view to the scroll view's content layout guide.
    private func addEmbeddedViewConstraints() {
        // See https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/WorkingwithScrollViews.html

        guard let embeddedView = embeddedView else {
            assertionFailure("The embedded view is undefined")
            return
        }

        let embeddedViewMinimumHeightConstraint = embeddedView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.safeAreaLayoutGuide.heightAnchor, multiplier: 1)
        self.embeddedViewMinimumHeightConstraint = embeddedViewMinimumHeightConstraint

        let scrollViewBottomAnchorConstraint = scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: embeddedView.bottomAnchor)
        self.scrollViewBottomAnchorConstraint = scrollViewBottomAnchorConstraint

        embeddedView.translatesAutoresizingMaskIntoConstraints = false
        let constraints: [NSLayoutConstraint] = [
            scrollView.contentLayoutGuide.leftAnchor.constraint(equalTo: embeddedView.leftAnchor),
            scrollView.contentLayoutGuide.rightAnchor.constraint(equalTo: embeddedView.rightAnchor),
            scrollView.contentLayoutGuide.topAnchor.constraint(equalTo: embeddedView.topAnchor),
            scrollViewBottomAnchorConstraint,
            embeddedView.widthAnchor.constraint(greaterThanOrEqualTo: scrollView.safeAreaLayoutGuide.widthAnchor, multiplier: 1),
            embeddedViewMinimumHeightConstraint,
            ]
        scrollView.addConstraints(constraints)
    }

    // Responds to changes in the size of the view, for example in response to device
    // orientation changes, by adjusting the scroll view's content offset to ensure
    // that it falls within a legal range.
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        let initialAdjustedContentInset = scrollView.adjustedContentInset
        let initialContentOffset = scrollView.contentOffset

        // When the device orientation changes, we'll receive a keyboardWillHide
        // notification, followed by a keyboardDidShow notification only after the device
        // orientation animation completes. If we responded to these immediately, this
        // would result in awkward view resizing animation, in particular when
        // keyboardAdjustmentBehavior was set to .adjustScrollViewAndEmbeddedView. To work
        // around this issue, we suspend KeyboardObserver's KeyboardFrameFilter during the
        // transition, and as a result, we'll respond only to the final size of the
        // keyboard after the animation completes.
        keyboardObserver?.suspend()

        coordinator.animate(alongsideTransition: { (context: UIViewControllerTransitionCoordinatorContext) in
            var contentOffset = initialContentOffset

            // At this point, if the keyboard is presented, it would be nice to keep the first
            // responder text field visible on the screen during the transition. However, it
            // appears that there's no way to know what the new size of the keyboard will be,
            // and by extension, the new size of the visible portion of the scroll view, which
            // would be necessary to accurately maintain the text field's visibility.
            // A survey of iOS 12's apps (e.g. creating a new event in Calendar, or editing a
            // document in Pages) reveals that Apple doesn't attempt to handle this case
            // elegantly either.

            // Pin the top left corner of the view. This matches the general behavior of
            // Apple's iOS apps.
            contentOffset = CGPoint(
                x: contentOffset.x + initialAdjustedContentInset.left - self.scrollView.adjustedContentInset.left,
                y: contentOffset.y + initialAdjustedContentInset.top - self.scrollView.adjustedContentInset.top)

            self.scrollView.contentOffset = self.constrainScrollViewContentOffset(contentOffset)
        }, completion: { (context: UIViewControllerTransitionCoordinatorContext) in
            self.keyboardObserver?.resume()
        })
    }

    /// Constrains a scroll view content offset so that it lies within the legal range
    /// of possible values for the rest state of the scroll view.
    ///
    /// - Parameter contentOffset: The content offset to constrain.
    /// - Returns: The constrained content offset.
    private func constrainScrollViewContentOffset(_ contentOffset: CGPoint) -> CGPoint {
        var contentOffset = contentOffset

        let contentSize = scrollView.contentSize
        let visibleContentSize = self.visibleContentSize(of: scrollView)
        let adjustedContentInset = scrollView.adjustedContentInset

        // Don't let the scroll view scroll up past its right/bottom extent. If we don't do
        // this, then if the view is shorter than the scroll view in portrait orientation,
        // and we scroll to the bottom in landscape orientation, and then change the
        // orientation back to portrait, the top of the view will be permanently shifted up
        // off the top of the screen, and there will no way for the user to scroll up to
        // see it.
        contentOffset.x = min(contentOffset.x, contentSize.width - visibleContentSize.width - adjustedContentInset.left)
        contentOffset.y = min(contentOffset.y, contentSize.height - visibleContentSize.height - adjustedContentInset.top)

        // Don't let the scroll view scroll down past its left/top extent. This isn't
        // strictly necessary because above we pin the top left corner of the view, but
        // we're doing this anyway, to support possible future changes to how we manage the
        // content offset.
        contentOffset.x = max(contentOffset.x, -adjustedContentInset.left)
        contentOffset.y = max(contentOffset.y, -adjustedContentInset.top)

        return contentOffset
    }

    /// The size of the region of the scroll view in which content is visible. This is
    /// size of the scroll view's bounds after its adjusted content inset has been
    /// applied.
    private func visibleContentSize(of scrollView: UIScrollView) -> CGSize {
        return scrollView.bounds.inset(by: scrollView.adjustedContentInset).size
    }

    /// Adjusts the ContainerScrollViewController to compensate for the portion of the
    /// keyboard that overlaps the view.
    ///
    /// - Parameter bottomInset: The height of the area of keyboard's frame that
    /// overlaps the view.
    func adjustViewForKeyboard(with bottomInset: CGFloat) {
        scrollViewBounceController.bottomInset = bottomInset

        switch keyboardAdjustmentBehavior {
        case .none:
            return
        case .adjustAdditionalSafeAreaInsets:
            // Adjust the view controller's additional safe area insets. This is the default
            // behavior.
            if shouldResizeEmbeddedViewForKeyboard {
                // Adjust the additional safe area insets, possibly reducing the size
                // of the embedded view.
                additionalSafeAreaInsets.bottom = bottomInset
            } else {
                // Adjust the additional safe area insets, but also increase the minimum height of
                // the embedded view to compensate. The size of the embedded view will
                // remain unchanged.
                additionalSafeAreaInsets.bottom = bottomInset
                embeddedViewMinimumHeightConstraint?.constant = bottomInset
            }
        case .adjustScrollViewContentSize:
            // Adjust the scroll view's content size. This approach leaves the view
            // controller's additional safe area insets untouched, but will result in
            // misaligned scroll indicators when the left and right safe area insets are
            // nonzero, for example in landscape orientation on iPhone X. This appears to be a
            // side effect of setting the bottom scroll indicator inset to a nonzero value.
            if shouldResizeEmbeddedViewForKeyboard {
                // Add padding to the bottom of the scroll view, but reduce the minimum allowed
                // height of the embedded view to compensate.
                scrollViewBottomAnchorConstraint?.constant = bottomInset
                embeddedViewMinimumHeightConstraint?.constant = -bottomInset
                scrollView.scrollIndicatorInsets.bottom = bottomInset
            } else {
                // Add padding to the bottom of the scroll view. The size of the embedded view will
                // remain unchanged.
                scrollViewBottomAnchorConstraint?.constant = bottomInset
                scrollView.scrollIndicatorInsets.bottom = bottomInset
            }
        }
    }

}
