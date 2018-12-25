//
//  PillButton.swift
//  Example
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
        tintColor = .white
    }

}
