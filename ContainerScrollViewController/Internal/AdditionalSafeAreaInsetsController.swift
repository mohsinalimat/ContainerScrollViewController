//
//  AdditionalSafeAreaInsetsController.swift
//  ContainerScrollViewController
//
//  Created by Drew Olbrich on 12/30/18.
//  Copyright © 2018 Drew Olbrich. All rights reserved.
//

import UIKit

/// An object that adjusts the container view's `additionalSafeAreaInsets.bottom`
/// property to compensate for the portion of the keyboard that overlaps the scroll
/// view.
class AdditionalSafeAreaInsetsController {

    private weak var containerScrollViewEmbedder: ContainerScrollViewEmbedder?

    /// The initial value of the `additionalSafeAreaInsets` property before the keyboard
    /// was presented. We'll restore `additionalSafeAreaInsets` to this value when the
    /// keyboard is dismissed.
    private var initialAdditionalSafeAreaInsets: UIEdgeInsets?

    init(containerScrollViewEmbedder: ContainerScrollViewEmbedder) {
        self.containerScrollViewEmbedder = containerScrollViewEmbedder
    }

    var bottomInset: CGFloat = 0 {
        didSet {
            guard let containerScrollViewEmbedder = containerScrollViewEmbedder,
                let embeddingViewController = containerScrollViewEmbedder.embeddingViewController,
                let embeddedViewMinimumHeightConstraint = containerScrollViewEmbedder.embeddedViewMinimumHeightConstraint else {
                    return
            }

            var adjustedBottomInset = bottomInset
            if bottomInset != 0 && oldValue == 0 {
                // The keyboard was presented.
                let initialAdditionalSafeAreaInsets = embeddingViewController.additionalSafeAreaInsets
                self.initialAdditionalSafeAreaInsets = initialAdditionalSafeAreaInsets
                adjustedBottomInset = max(adjustedBottomInset, initialAdditionalSafeAreaInsets.bottom)
            } else if bottomInset == 0 && oldValue != 0 {
                // The keyboard was dismissed.
                guard let initialAdditionalSafeAreaInset = initialAdditionalSafeAreaInsets else {
                    assertionFailure()
                    return
                }
                adjustedBottomInset = initialAdditionalSafeAreaInset.bottom
            } else if bottomInset != oldValue {
                // The keyboard changed size.
                guard let initialAdditionalSafeAreaInset = initialAdditionalSafeAreaInsets else {
                    assertionFailure()
                    return
                }
                adjustedBottomInset = max(adjustedBottomInset, initialAdditionalSafeAreaInset.bottom)
            } else {
                // The size of the keyboard is unchanged.
                return
            }

            if containerScrollViewEmbedder.shouldResizeEmbeddedViewForKeyboard {
                // Adjust the additional safe area insets, possibly reducing the size
                // of the embedded view.
                embeddingViewController.additionalSafeAreaInsets.bottom = adjustedBottomInset
            } else {
                // Adjust the additional safe area insets, but also increase the minimum height of
                // the embedded view to compensate. The size of the embedded view will
                // remain unchanged.
                embeddingViewController.additionalSafeAreaInsets.bottom = adjustedBottomInset
                embeddedViewMinimumHeightConstraint.constant = adjustedBottomInset
            }
        }
    }

}
