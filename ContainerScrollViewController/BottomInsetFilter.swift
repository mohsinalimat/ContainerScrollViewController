//
//  BottomInsetFilter.swift
//  ContainerScrollViewController
//
//  Created by Drew Olbrich on 12/26/18.
//  Copyright © 2018 Drew Olbrich. All rights reserved.
//

import UIKit

/// An object that applies a temporal filter to the scroll view's bottom additional
/// safe area inset, so rapid sequences of adjustments are filtered out.
///
/// When a text field becomes the first responder, or the first responder changes
/// when the user taps on another text field, UIKit will present the keyboard or
/// adjust its height if an input accessory view is specified.
///
/// Often, these changes will generate a sequence of keyboardWillShow notifications,
/// often with radically different values. As an extreme example, if a text field is
/// populated using the auto-fill input accessory view, and this action causes a
/// password text field to automatically become the first responder, one
/// keyboardWillHide notifications and two keyboardWillShow notifications will be
/// posted within the span of 0.1 seconds.
///
/// If KeyboardObserver responded to each of these notifications individually, this
/// would cause discontinuities in our scroll view animation that accompanies
/// keyboard changes.
///
/// To work around this issue, BottomInsetFilter filters out sequences of
/// notifications that occur within a small time window, acting only on the final
/// assigned bottom inset in the sequence.
class BottomInsetFilter {

    var delay: TimeInterval = 0.15

    private weak var delegate: BottomInsetFilterDelegate?

    var bottomInset: CGFloat = 0 {
        didSet {
            if bottomInset != oldValue {
                // Don't reset the timer or call the delegate if the bottom inset hasn't changed.
                didSetBottomInset()
            }
        }
    }

    public private(set) var presentationBottomInset: CGFloat = 0 {
        didSet {
            self.delegate?.keyboardAdjustmentFilter(self, didChangeBottomInset: self.presentationBottomInset)
        }
    }

    private var timer: Timer?

    init(delegate: BottomInsetFilterDelegate) {
        self.delegate = delegate
    }

    deinit {
        cancel()
    }

    func cancel() {
        timer?.invalidate()
    }

    func flush() {
        timer?.fire()
    }

    private func didSetBottomInset() {
        let timer = Timer(timeInterval: delay, repeats: false, block: { [weak self] (timer: Timer) in
            guard let self = self else {
                return
            }
            self.timer = nil
            self.presentationBottomInset = self.bottomInset
        })

        self.timer = timer

        // We use RunLoop.Mode.common instead of the default run loop mode, because
        // otherwise the timer will not fire while the scroll view is scrolling, which will
        // be the case when the user swipes to dismiss the keyboard when the scroll view's
        // keyboardDismissMode is set to interactive, in which case the scroll view's
        // bottom inset will be adjusted by KeyboardObserver only after an extended delay.
        RunLoop.current.add(timer, forMode: .common)
    }

}
