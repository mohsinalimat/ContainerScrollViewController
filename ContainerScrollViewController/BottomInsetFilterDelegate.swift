//
//  BottomInsetFilterDelegate.swift
//  ContainerScrollViewController
//
//  Created by Drew Olbrich on 12/26/18.
//  Copyright © 2018 Drew Olbrich. All rights reserved.
//

import UIKit

protocol BottomInsetFilterDelegate: class {

    func keyboardAdjustmentFilter(_ keyboardAdjustmentFilter: BottomInsetFilter, didChangeBottomInset bottomInset: CGFloat)

}
