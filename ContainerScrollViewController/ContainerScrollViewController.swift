//
//  ContainerScrollViewController.swift
//  ContainerScrollViewController
//
//  Created by Drew Olbrich on 12/19/18.
//  Copyright © 2018 Drew Olbrich. All rights reserved.
//
//  Distributed under the MIT License.
//
//  Get the latest version from here:
//  https://github.com/milpitas/ContainerScrollViewController
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit

/// A view controller that manages a scroll view, within which another view
/// controller is embedded. The scroll view's content size is adjusted to reflect
/// the embedded view's Auto Layout constraints.
open class ContainerScrollViewController: UIViewController {

    /// The scroll view within which another view will be embedded.
    public let scrollView = UIScrollView()

    /// The view controller embedded within the container scroll view.
    public private(set) var embeddedViewController: UIViewController?

    /// The behavior for adjusting the view when the keyboard is presented. The default
    /// value of this property is `.updateAdditionalSafeAreaInsets`.
    public enum KeyboardAdjustmentBehavior {
        /// Don't adjust the scroll view when the keyboard is presented.
        case none
        /// Compensate for the presented keyboard by resizing the scroll view's safe area.
        case resizeSafeArea
        /// Compensate for the presented keyboard by resizing the scroll view's embedded view.
        case resizeEmbeddedView
    }

    /// The behavior for adjusting the view when the keyboard is presented.
    public var keyboardAdjustmentBehavior: KeyboardAdjustmentBehavior = .resizeSafeArea {
        willSet {
            // This property cannot be modified while the view is visible. The viewWillAppear
            // and viewDidDisappear methods add and remove keyboard visibility notification
            // observers only if keyboardAdjustmentBehavior is not .none, and the state of
            // these notification observers would become inconsistent otherwise.
            assert(view.window == nil, "keyboardAdjustmentBehavior may only be modified when the view isn't visible")
        }
    }

    // This property is true if viewDidLoad has already been called.
    private var viewDidLoadWasCalled = false

    // The embedded view's height constraint. We use this to compensate for the change
    // we make to the bottom adjusted safe area inset when the keyboard is presented,
    // so that the embedded view's height doesn't change, even though it is constrained
    // to the height of the safe area, which usually includes the adjusted safe area inset.
    internal var embeddedViewHeightConstraint: NSLayoutConstraint?

    private lazy var containerScrollViewKeyboardObserver = ContainerScrollViewKeyboardObserver(containerScrollViewController: self)

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

        let firstSubview = view.subviews.first

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

        guard let embeddedView = firstSubview else {
            // The view controller's view had no subviews. It's assumed that the view
            // controller will embed a view controller manually by calling embedViewController
            // in viewDidLoad.
            return
        }

        scrollView.addSubview(embeddedView)

        addScrollViewEmbeddedViewConstraints()
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
        assert(self.embeddedViewController == nil, "Only one view controller may be embedded in an ContainerScrollViewController")

        self.embeddedViewController = embeddedViewController

        addChild(embeddedViewController)
        scrollView.addSubview(embeddedViewController.view)
        embeddedViewController.didMove(toParent: self)

        addScrollViewEmbeddedViewConstraints()
    }

    /// Constrains the embedded view to the scroll view's content layout guide.
    private func addScrollViewEmbeddedViewConstraints() {
        // See https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/WorkingwithScrollViews.html

        guard let embeddedView = embeddedViewController?.view else {
            assertionFailure("Embedded view controller is undefined")
            return
        }

        let embeddedViewHeightConstraint = embeddedView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.safeAreaLayoutGuide.heightAnchor, multiplier: 1)
        self.embeddedViewHeightConstraint = embeddedViewHeightConstraint

        embeddedView.translatesAutoresizingMaskIntoConstraints = false
        let constraints: [NSLayoutConstraint] = [
            scrollView.contentLayoutGuide.leftAnchor.constraint(equalTo: embeddedView.leftAnchor),
            scrollView.contentLayoutGuide.rightAnchor.constraint(equalTo: embeddedView.rightAnchor),
            scrollView.contentLayoutGuide.topAnchor.constraint(equalTo: embeddedView.topAnchor),
            scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: embeddedView.bottomAnchor),
            embeddedView.widthAnchor.constraint(greaterThanOrEqualTo: scrollView.safeAreaLayoutGuide.widthAnchor, multiplier: 1),
            embeddedViewHeightConstraint,
            ]
        scrollView.addConstraints(constraints)
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        containerScrollViewKeyboardObserver.addObservers()

        assert(embeddedViewController != nil, "Either embedViewController must be called in viewDidLoad, or a container view controller relationship must be established in Interface Builder, in which case prepare(for:sender:), if overridden, must call super.prepare(for:sender:)")
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        containerScrollViewKeyboardObserver.removeObservers()
    }

    // Responds to changes in the size of the view, for example in response to device
    // orientation changes, by adjusting the scroll view's content offset to ensure
    // that it falls within a legal range.
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        let initialAdjustedContentInset = scrollView.adjustedContentInset
        let initialContentOffset = scrollView.contentOffset

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
        }, completion: nil)
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

}
