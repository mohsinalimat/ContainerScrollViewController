//
//  StoryboardSignUpViewController.swift
//  StoryboardExample
//
//  Created by Drew Olbrich on 12/23/18.
//  Copyright © 2018 Drew Olbrich. All rights reserved.
//

import UIKit
import ContainerScrollViewController

class StoryboardSignUpViewController: ContainerScrollViewController {

    private var signUpEmbeddedViewController: SignUpEmbeddedViewController? {
        return embeddedViewController as? SignUpEmbeddedViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        shouldResizeEmbeddedViewForKeyboard = true

        scrollView.keyboardDismissMode = .interactive
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
