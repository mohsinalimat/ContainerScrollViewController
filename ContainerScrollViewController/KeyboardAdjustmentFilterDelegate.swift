//
//  KeyboardAdjustmentFilterDelegate.swift
//  ContainerScrollViewController
//
//  Created by Drew Olbrich on 12/26/18.
//  Copyright © 2018 Drew Olbrich. All rights reserved.
//

import UIKit

protocol KeyboardAdjustmentFilterDelegate: class {

    func keyboardAdjustmentFilter(_ keyboardAdjustmentFilter: KeyboardAdjustmentFilter, didChangeBottomInset bottomInset: CGFloat)

}
