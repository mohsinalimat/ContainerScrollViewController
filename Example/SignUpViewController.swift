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

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.keyboardDismissMode = .interactive
    }

}
