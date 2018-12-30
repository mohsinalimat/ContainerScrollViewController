//
//  SignUpBackgroundView.swift
//  Examples
//
//  Created by Drew Olbrich on 12/24/18.
//  Copyright © 2018 Drew Olbrich. All rights reserved.
//

import UIKit

class SignUpBackgroundView: UIView {

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        commonInit()
    }

    private func commonInit() {
        guard let gradientLayer = layer as? CAGradientLayer else {
            assertionFailure()
            return
        }

        gradientLayer.colors = [
            UIColor(red: 37/255, green: 176/255, blue: 176/255, alpha: 1).cgColor,
            UIColor(red: 72/255, green: 72/255, blue: 171/255, alpha: 1).cgColor,
        ]
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard let gradientLayer = layer as? CAGradientLayer else {
            assertionFailure()
            return
        }

        gradientLayer.startPoint = CGPoint(x: 0.2, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.8, y: 1)
    }

}
