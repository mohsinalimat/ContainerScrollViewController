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
/// the embedded view is short enough that scrolling wouldn't normally be permitted.
class ScrollViewBounceController {

    private weak var containerScrollViewEmbedder: ContainerScrollViewEmbedder?

    private var initialAlwaysBounceVertical: Bool?

    init(containerScrollViewEmbedder: ContainerScrollViewEmbedder) {
        self.containerScrollViewEmbedder = containerScrollViewEmbedder
    }

    var bottomInset: CGFloat = 0 {
        didSet {
            guard let scrollView = containerScrollViewEmbedder?.scrollView,
                scrollView.keyboardDismissMode != .none else {
                return
            }

            if bottomInset != 0 && oldValue == 0 {
                // The keyboard was presented.
                initialAlwaysBounceVertical = scrollView.alwaysBounceVertical
                scrollView.alwaysBounceVertical = true
            } else if bottomInset == 0 && oldValue != 0 {
                // The keyboard was dismissed.
                guard let initialAlwaysBounceVertical = initialAlwaysBounceVertical else {
                    assertionFailure()
                    return
                }
                scrollView.alwaysBounceVertical = initialAlwaysBounceVertical
                self.initialAlwaysBounceVertical = nil
            }
        }
    }

}
