//
//  UIResponder+Current.swift
//  ContainerScrollViewController
//
//  Created by Drew Olbrich on 12/29/18.
//  Copyright © 2018 Drew Olbrich. All rights reserved.
//

// Based on https://stackoverflow.com/a/52823735/2419404

import UIKit

private var foundFirstResponder: UIResponder? = nil

extension UIResponder {

    static var rf_current: UIResponder? {
        UIApplication.shared.sendAction(#selector(UIResponder.storeFirstResponder(_:)), to: nil, from: nil, for: nil)
        defer {
            foundFirstResponder = nil
        }
        return foundFirstResponder
    }

    @objc private func storeFirstResponder(_ sender: AnyObject) {
        foundFirstResponder = self
    }
}


