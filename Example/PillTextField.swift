//
//  PillTextField.swift
//  Example
//
//  Created by Drew Olbrich on 12/24/18.
//  Copyright © 2018 Drew Olbrich. All rights reserved.
//

import UIKit

class PillTextField: UITextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        commonInit()
    }

    private func commonInit() {
        borderStyle = .none

        let fillColor = UIColor(white: 1, alpha: 0.1)
        let outlineColor = UIColor(white: 1, alpha: 0.15)
        let placeholderColor = UIColor(white: 1, alpha: 0.4)

        background = roundedCornersImage(fillColor: fillColor, outlineColor: outlineColor, cornerRadius: bounds.height/2)

        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: placeholderColor,
            .font: UIFont.systemFont(ofSize: 17, weight: .medium),
        ]
        if let placeholder = placeholder {
            attributedPlaceholder = NSAttributedString(string: placeholder, attributes: placeholderAttributes)
        }

        font = UIFont.systemFont(ofSize: 17, weight: .medium)
        textColor = .white

        // The insertion point's color and the color of selected text.
        tintColor = .white
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: round(bounds.height*0.45), dy: 0)
    }

}
