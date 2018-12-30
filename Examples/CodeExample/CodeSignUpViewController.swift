//
//  CodeSignUpViewController.swift
//  CodeExample
//
//  Created by Drew Olbrich on 12/29/18.
//  Copyright © 2018 Drew Olbrich. All rights reserved.
//

import UIKit
import ContainerScrollViewController

class CodeSignUpViewController: ContainerScrollViewController {

    private var signUpEmbeddedViewController: SignUpEmbeddedViewController? {
        return embeddedViewController as? SignUpEmbeddedViewController
    }

    override func loadView() {
        view = SignUpBackgroundView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let signUpEmbeddedViewController = createSignUpEmbeddedViewController()

        embedViewController(signUpEmbeddedViewController)

        shouldResizeEmbeddedViewForKeyboard = true

        scrollView.keyboardDismissMode = .interactive
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    /// Creates the Sign Up embedded view controller. This example app is intended to
    /// demonstrate how to use ContainerScrollViewController with code only, but we're
    /// cheating and loading the embedded view controller out of our Storyboard file. In
    /// a real app, this view controller could be created in code.
    func createSignUpEmbeddedViewController() -> SignUpEmbeddedViewController {
        let bundle = Bundle(for: CodeSignUpViewController.self)
        let storyboard = UIStoryboard(name: "Shared", bundle: bundle)
        guard let signUpEmbeddedViewController = storyboard.instantiateViewController(withIdentifier: "signUpEmbeddedViewController") as? SignUpEmbeddedViewController else {
            fatalError("Unable to load signUpEmbeddedViewController")
        }
        return signUpEmbeddedViewController
    }

}
