//
//  SignUpViewController.swift
//  Example
//
//  Created by Drew Olbrich on 12/23/18.
//  Copyright © 2018 Drew Olbrich. All rights reserved.
//

import UIKit
import ContainerScrollViewController

class SignUpViewController: ContainerScrollViewController {

    private var signUpEmbeddedViewController: SignUpEmbeddedViewController? {
        return embeddedViewController as? SignUpEmbeddedViewController
    }

    override var childForStatusBarStyle: UIViewController? {
        return signUpEmbeddedViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        keyboardAdjustmentBehavior = .adjustAdditionalSafeAreaInsets

        shouldResizeEmbeddedViewForKeyboard = true

        scrollView.keyboardDismissMode = .interactive
    }

}
