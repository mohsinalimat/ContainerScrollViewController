//
//  EmbedderSignUpViewController.swift
//  EmbedderExample
//
//  Created by Drew Olbrich on 12/29/18.
//  Copyright © 2018 Drew Olbrich. All rights reserved.
//

import UIKit
import ContainerScrollViewController

/// A class that demonstrates configuring a container scroll view controller in
/// Interface Builder using storyboards, but using the `ContainerScrollViewEmbedder`
/// helper class instead of subclassing `ContainerScrollViewController`.
class EmbedderSignUpViewController: UIViewController {

    /// Convenience property for accessing the embedded view controller.
    var signUpEmbeddedViewController: SignUpEmbeddedViewController? {
        return containerScrollViewEmbedder.embeddedViewController as? SignUpEmbeddedViewController
    }

    /// Helper class that handles the view controller embedding instead of
    /// `ContainerScrollViewController`.
    lazy var containerScrollViewEmbedder = ContainerScrollViewEmbedder(embeddingViewController: self)

    override func viewDidLoad() {
        super.viewDidLoad()

        containerScrollViewEmbedder.viewDidLoad()

        // Allow the embedded view to shrink vertically when the keyboard is presented.
        containerScrollViewEmbedder.shouldResizeEmbeddedViewForKeyboard = true

        // Allow the user to dismiss the keyboard by dragging from the scroll view to the
        // bottom of the screen.
        containerScrollViewEmbedder.scrollView.keyboardDismissMode = .interactive
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        containerScrollViewEmbedder.prepare(for: segue, sender: sender)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        containerScrollViewEmbedder.viewWillTransition(to: size, with: coordinator)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
