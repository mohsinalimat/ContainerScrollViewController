//
//  SignUpEmbeddedViewController.swift
//  Example
//
//  Created by Drew Olbrich on 12/23/18.
//  Copyright © 2018 Drew Olbrich. All rights reserved.
//

import UIKit

class SignUpEmbeddedViewController: UIViewController {

    @IBOutlet weak var logoImageView: UIImageView!

    @IBOutlet weak var signInButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        logoImageView.tintColor = .white

        signInButton.tintColor = .white
    }
}
