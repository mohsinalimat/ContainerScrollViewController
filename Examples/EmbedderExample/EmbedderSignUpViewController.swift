//
//  EmbedderSignUpViewController.swift
//  EmbedderExample
//
//  Created by Drew Olbrich on 12/29/18.
//  Copyright © 2018 Drew Olbrich. All rights reserved.
//

import UIKit
import ContainerScrollViewController

class EmbedderSignUpViewController: UIViewController {

    lazy var containerScrollViewEmbedder = ContainerScrollViewEmbedder(embeddingViewController: self)

    override func viewDidLoad() {
        super.viewDidLoad()

        containerScrollViewEmbedder.viewDidLoad()

        containerScrollViewEmbedder.shouldResizeEmbeddedViewForKeyboard = true

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
