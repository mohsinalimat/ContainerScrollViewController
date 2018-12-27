//
//  KeyboardFrameFilterDelegate.swift
//  ContainerScrollViewController
//
//  Created by Drew Olbrich on 12/26/18.
//  Copyright © 2018 Drew Olbrich. All rights reserved.
//

import UIKit

/// Delegate of the `KeyboardFrameFilterDelegate` object.
protocol KeyboardFrameFilterDelegate: class {

    /// Tells the delegate that `presentationKeyboardFrame` has changed.
    ///
    /// When `KeyboardFrameFilter.keyboardFrame` changes, this delegate method is called
    /// only after a short period of time elapses.
    ///
    /// - Parameters:
    ///   - keyboardFrameFilter: The object tracking changes to the bottom inset.
    ///   - keyboardFrame: The new keyboard frame to present to the user.
    func keyboardAdjustmentFilter(_ keyboardFrameFilter: KeyboardFrameFilter, didChangeKeyboardFrame keyboardFrame: CGRect?)

}
