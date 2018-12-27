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

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        logoImageView.tintColor = .white

        let signInButtonTitleColor: UIColor = .white
        let signInButtonTitleFontSize: CGFloat = 15

        let signInButtonTitle = NSMutableAttributedString()

        let signInButtonTitleRegularFontAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: signInButtonTitleColor,
            .font: UIFont.systemFont(ofSize: signInButtonTitleFontSize, weight: .regular),
            ]
        let signInButtonTitleMediumFontAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: signInButtonTitleColor,
            .font: UIFont.systemFont(ofSize: signInButtonTitleFontSize, weight: .medium),
            ]

        signInButtonTitle.append(NSAttributedString(string: "Already have an account? ", attributes: signInButtonTitleRegularFontAttributes))
        signInButtonTitle.append(NSAttributedString(string: "Sign In", attributes: signInButtonTitleMediumFontAttributes))

        signInButton.setAttributedTitle(signInButtonTitle, for: .normal)
    }

}
