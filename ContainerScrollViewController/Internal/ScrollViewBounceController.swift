//
//  ScrollViewBounceController.swift
//  ContainerScrollViewController
//
//  Created by Drew Olbrich on 12/27/18.
//  Copyright © 2018 Drew Olbrich. All rights reserved.
//

import UIKit

class ScrollViewBounceController {

    weak var scrollView: UIScrollView?

    private var initialAlwaysBounceVertical: Bool = false

    init(scrollView: UIScrollView) {
        self.scrollView = scrollView
    }

    var bottomInset: CGFloat = 0 {
        didSet {
            guard scrollView?.keyboardDismissMode != .none else {
                return
            }

            if bottomInset != 0 && oldValue == 0 {
                initialAlwaysBounceVertical = scrollView?.alwaysBounceVertical == true
                scrollView?.alwaysBounceVertical = true
            } else if bottomInset == 0 && oldValue != 0 {
                scrollView?.alwaysBounceVertical = initialAlwaysBounceVertical
            }
        }
    }

}
