//
//  CodeSignUpViewController.swift
//  CodeExample
//
//  Created by Drew Olbrich on 12/29/18.
//  Copyright © 2018 Drew Olbrich. All rights reserved.
//

import UIKit
import ContainerScrollViewController

/// A class that demonstrates configuring `ContainerScrollViewController`
/// programmatically. This view controller is instantiated in `AppDelegate` and
/// installed as the window's root view controller.
class CodeSignUpViewController: ContainerScrollViewController {

    /// Convenience property for accessing the embedded view controller.
    var signUpEmbeddedViewController: SignUpEmbeddedViewController? {
        return embeddedViewController as? SignUpEmbeddedViewController
    }

    override func loadView() {
        // Assign a gradient as the background view.
        view = SignUpBackgroundView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Embed the SignUpEmbeddedViewController in the container scroll view.
        let signUpEmbeddedViewController = createSignUpEmbeddedViewController()
        embedViewController(signUpEmbeddedViewController)

        // Allow the embedded view to shrink vertically when the keyboard is presented.
        shouldResizeEmbeddedViewForKeyboard = true

        // Allow the user to dismiss the keyboard by dragging from the scroll view to the
        // bottom of the screen.
        scrollView.keyboardDismissMode = .interactive
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    /// Creates the Sign Up embedded view controller. This example app is intended to
    /// demonstrate how to use ContainerScrollViewController with code only, but we're
    /// cheating and loading the embedded view controller out of our Storyboard file. In
    /// a real app, this view controller could be created in code, as long as its width
    /// and height can be determined using Auto Layout constraints.
    func createSignUpEmbeddedViewController() -> SignUpEmbeddedViewController {
        let bundle = Bundle(for: CodeSignUpViewController.self)
        let storyboard = UIStoryboard(name: "Shared", bundle: bundle)
        guard let signUpEmbeddedViewController = storyboard.instantiateViewController(withIdentifier: "signUpEmbeddedViewController") as? SignUpEmbeddedViewController else {
            fatalError("Unable to load signUpEmbeddedViewController")
        }
        return signUpEmbeddedViewController
    }

}
