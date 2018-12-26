//
//  BottomInsetFilter.swift
//  ContainerScrollViewController
//
//  Created by Drew Olbrich on 12/26/18.
//  Copyright © 2018 Drew Olbrich. All rights reserved.
//

import UIKit

/// An object that applies a temporal filter to the scroll view's bottom additional
/// safe area inset, so that rapid sequences of adjustments are filtered out.
///
/// When a text field becomes the first responder, UIKit presents the keyboard. If
/// the user taps on another text field, changing the first responder, UIKit may
/// adjust the keyboard's height if an input accessory view is specified. Often,
/// these changes will generate a sequence of `keyboardWillShow` notifications, each
/// with different keyboard heights.
///
/// As an extreme example, if the user populates a text field by tapping on an
/// AutoFill input accessory view, and this action causes a password text field to
/// automatically become the first responder, one `keyboardWillHide` notifications
/// and two `keyboardWillShow` notifications will be posted within the span of 0.1
/// seconds.
///
/// If `KeyboardObserver` were to respond to each of these notifications
/// individually, this would cause awkward discontinuities in our scroll view
/// animation that accompanies changes to the keyboard's height.
///
/// To work around this issue, `BottomInsetFilter` filters out sequences of
/// notifications that occur within a small time window, acting only on the final
/// assigned bottom inset in the sequence.
class BottomInsetFilter {

    /// The delay before a change to `bottomInset` will result in a corresponding change
    /// to `presentationBottomInset`.
    var delay: TimeInterval = 0.15

    /// The delegate that is called when `presentationBottomInset` changes.
    private weak var delegate: BottomInsetFilterDelegate?

    /// The additional safe area bottom inset that `KeyboardObserver` applies to the
    /// scroll view to account for the keyboard. When this value changes, the delegate's
    /// `keyboardAdjustmentFilter(_:didChangeBottomInset:)` is called after a short
    /// delay. Repeated changes to `bottomInset` that occur within this period are
    /// collapsed, resulting in a single delegate call.
    var bottomInset: CGFloat = 0 {
        didSet {
            if bottomInset != oldValue {
                startTimer()
            }
        }
    }

    /// The final bottom inset that should be presented to the user, after temporal
    /// filtering has been applied. This is the value reported by the last
    /// `keyboardAdjustmentFilter(_:didChangeBottomInset:)` delegate call.
    public private(set) var presentationBottomInset: CGFloat = 0 {
        didSet {
            self.delegate?.keyboardAdjustmentFilter(self, didChangeBottomInset: self.presentationBottomInset)
        }
    }

    /// The timer used to apply the temporal filter.
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

    /// Starts the timer that filters changes to the scroll view's bottom inset.
    private func startTimer() {
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
