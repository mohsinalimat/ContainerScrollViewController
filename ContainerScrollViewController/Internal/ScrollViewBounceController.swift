//
//  ScrollViewBounceController.swift
//  ContainerScrollViewController
//
//  Created by Drew Olbrich on 12/27/18.
//  Copyright © 2018 Drew Olbrich. All rights reserved.
//

import UIKit

/// An object that modifies the scroll view's `alwaysBounceVertical` property to
/// reflect the state of the presented keyboard. This ensures that when
/// `keyboardDismissMode` is set to `.interactive` it will work as expected, even if
/// the embedded view is short enough to not require scrolling.
class ScrollViewBounceController {

    weak var scrollView: UIScrollView?

    private var initialAlwaysBounceVertical: Bool?

    init(scrollView: UIScrollView) {
        self.scrollView = scrollView
    }

    var bottomInset: CGFloat = 0 {
        didSet {
            guard let scrollView = scrollView,
                scrollView.keyboardDismissMode != .none else {
                return
            }

            if bottomInset != 0 && oldValue == 0 {
                initialAlwaysBounceVertical = scrollView.alwaysBounceVertical
                scrollView.alwaysBounceVertical = true
            } else if bottomInset == 0 && oldValue != 0 {
                guard let initialAlwaysBounceVertical = initialAlwaysBounceVertical else {
                    assertionFailure()
                    return
                }
                scrollView.alwaysBounceVertical = initialAlwaysBounceVertical
            }
        }
    }

}
