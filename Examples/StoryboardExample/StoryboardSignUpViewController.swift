//
//  StoryboardSignUpViewController.swift
//  StoryboardExample
//
//  Created by Drew Olbrich on 12/23/18.
//  Copyright © 2018 Drew Olbrich. All rights reserved.
//

import UIKit
import ContainerScrollViewController

/// A class that demonstrates configuring `ContainerScrollViewController` in
/// Interface Builder using storyboards.
class StoryboardSignUpViewController: ContainerScrollViewController {

    /// Convenience property for accessing the embedded view controller.
    var signUpEmbeddedViewController: SignUpEmbeddedViewController? {
        return embeddedViewController as? SignUpEmbeddedViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Allow the embedded view to shrink vertically when the keyboard is presented.
        shouldResizeEmbeddedViewForKeyboard = true

        // Allow the user to dismiss the keyboard by dragging from the scroll view to the
        // bottom of the screen.
        scrollView.keyboardDismissMode = .interactive
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
