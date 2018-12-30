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

        let bundle = Bundle(for: CodeSignUpViewController.self)
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        let signUpEmbeddedViewController = storyboard.instantiateViewController(withIdentifier: "signUpEmbeddedViewController")
        embedViewController(signUpEmbeddedViewController)

        shouldResizeEmbeddedViewForKeyboard = true

        scrollView.keyboardDismissMode = .interactive
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
