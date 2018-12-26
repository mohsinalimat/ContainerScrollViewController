//
//  BottomInsetFilter.swift
//  ContainerScrollViewController
//
//  Created by Drew Olbrich on 12/26/18.
//  Copyright © 2018 Drew Olbrich. All rights reserved.
//

import UIKit

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
