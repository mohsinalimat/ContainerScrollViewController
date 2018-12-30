//
//  RoundedCornersImage.swift
//  Examples
//
//  Created by Drew Olbrich on 12/24/18.
//  Copyright © 2018 Drew Olbrich. All rights reserved.
//

import UIKit

func roundedCornersImage(fillColor: UIColor?, outlineColor: UIColor?, cornerRadius: CGFloat, outlineWidth: CGFloat = 1) -> UIImage? {
    let size = CGSize(width: cornerRadius*2, height: cornerRadius*2)
    let rect = CGRect(origin: .zero, size: size)

    UIGraphicsBeginImageContext(size)

    guard let context = UIGraphicsGetCurrentContext() else {
        return nil
    }

    context.clear(rect)

    // Fill.
    if let fillColor = fillColor {
        context.setFillColor(fillColor.cgColor)
        context.fillEllipse(in: rect)
    }

    // Outline.
    if let outlineColor = outlineColor {
        context.setStrokeColor(outlineColor.cgColor)
        context.strokeEllipse(in: rect.insetBy(dx: outlineWidth/2, dy: outlineWidth/2))
    }

    let image = UIGraphicsGetImageFromCurrentImageContext()

    UIGraphicsEndImageContext()

    let capInsets = UIEdgeInsets(top: cornerRadius, left: cornerRadius, bottom: cornerRadius, right: cornerRadius)

    return image?.resizableImage(withCapInsets: capInsets)
}
