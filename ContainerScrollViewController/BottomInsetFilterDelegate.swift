//
//  BottomInsetFilterDelegate.swift
//  ContainerScrollViewController
//
//  Created by Drew Olbrich on 12/26/18.
//  Copyright © 2018 Drew Olbrich. All rights reserved.
//

import UIKit

/// Delegate of the `BottomInsetFilterDelegate` object.
protocol BottomInsetFilterDelegate: class {

    /// Tells the delegate that `presentationBottomInset` has changed.
    ///
    /// When `BottomInsetFilter.bottomInset` changes, this delegate method is called
    /// only after a short period of time elapses.
    ///
    /// - Parameters:
    ///   - bottomInsetFilter: The object tracking changes to the bottom inset.
    ///   - bottomInset: The new bottom inset to present to the user.
    func keyboardAdjustmentFilter(_ bottomInsetFilter: BottomInsetFilter, didChangeBottomInset bottomInset: CGFloat)

}
