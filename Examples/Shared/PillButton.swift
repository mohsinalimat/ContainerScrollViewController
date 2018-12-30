//
//  PillButton.swift
//  Examples
//
//  Created by Drew Olbrich on 12/24/18.
//  Copyright © 2018 Drew Olbrich. All rights reserved.
//

import UIKit

class PillButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        commonInit()
    }

    private func commonInit() {
        let normalOutlineColor = UIColor(white: 1, alpha: 0.4)
        let normalBackgroundImage = roundedCornersImage(fillColor: nil, outlineColor: normalOutlineColor, cornerRadius: bounds.height/2)

        let disabledOutlineColor = UIColor(white: 1, alpha: 0.25)
        let disabledBackgroundImage = roundedCornersImage(fillColor: nil, outlineColor: disabledOutlineColor, cornerRadius: bounds.height/2)

        setBackgroundImage(normalBackgroundImage, for: .normal)
        setBackgroundImage(disabledBackgroundImage, for: .disabled)

        adjustsImageWhenHighlighted = false
        adjustsImageWhenDisabled = false

        titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)

        setTitleColor(.white, for: .normal)
        setTitleColor(disabledOutlineColor, for: .disabled)
    }

}
