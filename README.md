# ContainerScrollViewController

[![Travis](https://img.shields.io/travis/milpitas/ContainerScrollViewController.svg)](https://travis-ci.org/milpitas/ContainerScrollViewController)
[![Platform](https://img.shields.io/badge/platform-iOS-lightgray.svg)](http://developer.apple.com/ios)
[![Swift 4.2](https://img.shields.io/badge/swift-4.2-red.svg?style=flat)](https://developer.apple.com/swift)
[![License](https://img.shields.io/github/license/milpitas/ContainerScrollViewController.svg)](https://tldrlegal.com/license/mit-license)
[![Twitter](https://img.shields.io/badge/twitter-@drewolbrich-blue.svg)](http://twitter.com/drewolbrich)

* [Purpose](#purpose)
* [Installation](#installation)
* [Usage](#usage)
* [Properties](#properties)
* [Methods](#methods)
* [Caveats](#caveats)
* [Usage Without Subclassing](#usage-without-subclassing)
* [How it Works](#how-it-works)
* [Special Cases Handled](#special-cases-handled)

## Purpose

A common UIKit Auto Layout task involves creating a view controller with a static layout that is too large to fit older, smaller devices, or devices in landscape orientation, or the area of the screen above the keyboard.

For example, consider this sign up screen, which fits on an iPhone XS, but not on an iPhone SE when the keyboard is presented:

<< iPhone XS and SE screenshots, with and without the keyboard >>

It's possible to handle this case in Interface Builder by manually nesting the view inside a scroll view, as described by Apple's [Working with Scroll Views](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/WorkingwithScrollViews.html) documentation, but this approach can be awkward. According to the Medium article [How to configure a UIScrollView with Auto Layout in Interface Builder](https://medium.com/@pradeep_chauhan/how-to-configure-a-uiscrollview-with-auto-layout-in-interface-builder-218dcb4022d7), 17 steps are required.

ContainerScrollViewController makes this task more pleasant by using Interface Builder's container view feature to embed a view controller in a scroll view. The embedded view controllers's contents can then be manipulated separately in Interface Builder.

<< Interface Builder embedding screenshot >>

ContainerScrollViewController also takes care of several tricky edge cases involving the keyboard and device rotations. 

## Installation

To install ContainerScrollViewController using CocoaPods, add the following to your Podfile:

```
pod 'ContainerScrollViewController'
```

## Usage

Subclasses of `ContainerScrollViewController` may be configured using storyboards or in code.

It's also possible to use either of these approaches without subclassing, and instead use an arbitrary view controller in conjunction with the helper class `ContainerScrollViewEmbedder`. This is described below in the section [Usage Without Subclassing](#usage-without-subclassing).     

### Storyboards

To create a container scroll view controller and its embedded view controller in a storyboard:

1. Subclass `ContainerScrollViewController`.

2. In Interface Builder, create a new view controller and set its class to your  `ContainerScrollViewController` subclass.

    << Screenshot >> 

3. In the outline view, delete the new view controller's view.

    << Screenshot >> 

4. Create a new container view and drag it into the view controller, replacing the view you just deleted.

    << Screenshot >> 

5. Set the container view's background color to anything other than transparent, which is the default value for Interface Builder's container views. Otherwise, it will appear black.

    << Screenshot >> 

If you have an existing view controller that you'd like to embed in the container view controller instead of the embedded view controller that
Interface Builder created along with the container view, follow these additional steps:

6. Delete the view controller that Interface Builder created as the destination of the container view's embed segue.

    << Screenshot >> 

7. Create a new embed segue from the container scroll view controller to your existing view controller.

    << Screenshot >> 

### Code

To integrate `ContainerScrollViewController` programmatically:

1. Subclass `ContainerScrollViewController`.

2. In `viewDidLoad`, call `embedViewController` with the view controller you'd like to embed in the container view controller's scroll view.

### Auto Layout Considerations

**IMPORTANT** - For ContainerScrollViewController to determine the height of the scroll view's content, the embedded view must contain an unbroken chain of constraints and views stretching from the content view’s top edge to its bottom edge. This is also true for the embedded view's width. This is consistent with the approach described by Apple's [Working with Scroll Views](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/WorkingwithScrollViews.html) documentation.

If insufficient Auto Layout constraints are defined, the embedded view will not scroll correctly. 

The easiest way to do this while avoiding Auto Layout constraint errors is to create a bottom alignment constraint with a low priority (less than 250).

<< Screenshot >>

### Oversized Embedded View Controllers

It's possible to make the embedded view controller larger than the height of the screen, even for large devices. To do this, change the embedded view controller's simulated size to Freeform and adjust the view's size.

<< Screenshot >>

## Properties

### shouldResizeEmbeddedViewForKeyboard

A boolean value that determines whether or not the embedded view is resized when the keyboard is presented.

* `true` - When the keyboard is presented, the embedded view shrinks to fit the portion of the scroll view not overlapped by the keyboard, to the extent that this is permitted by the embedded view's Auto Layout constraints. With an appropriate use of constraints, this may allow for more effective use of the reduced screen real estate. 

* `false` - When the keyboard is presented, the embedded view's size remains unchanged. This is the default value.

### shouldAdjustContainerViewForKeyboard

A boolean value that determines whether or not the container view controller's `additionalSafeAreaInsets` property is adjusted when the keyboard is presented.

* `true` - When the keyboard is presented, the container view controller's `additionalSafeAreaInsets.bottom` property is adjusted to compensate for the portion of the scroll view that is overlapped by the keyboard, ensuring that all of the embedded view's content is accessible via scrolling. This is the default value.

* `false` - When the keyboard is presented, the container view controller's `additionalSafeAreaInsets` property remains unchanged. Use this value to implement your own keyboard presentation compensation behavior.

### shouldScrollFirstResponderToVisibleForKeyboard

A boolean value that determines whether or not the scroll view will automatically scroll to make the first responder visible in response to keyboard changes.

* `true` - When the keyboard is presented or changes size, for example in response to a device orientation change, the scroll view scrolls to make the first responder visible. This is the default value.

* `false` - No special action is taken in response to keyboard changes. Even if this is set to `false`, UIKit may scroll the first responder to visible, although this may not work correctly in all cases. Use this value to override ContainerScrollViewController's default first responder visibility scrolling behavior.

### visibilityScrollMargin

A floating point value representing a vertical margin applied to the first responder view frame when the scroll view is automatically scrolled to make the first responder visible. The default value is 0, which matches the UIKit default behavior.

### embeddedViewController

The view controller embedded in the scroll view. You may want to define a downcasting method for convenient access: 

```swift
var myEmbeddedViewController: MyEmbeddedViewController? {
    return embeddedViewController as? MyEmbeddedViewController
}
```

## Methods

### scrollRectToVisible(animated:margin:)

Adjusts the scroll view to make the rect visible.

The optional `margin` parameter specifies an extra margin around the rect which is also made visible. If the `margin` parameter is unspecified or `nil`, the value of `visibilityScrollMargin` will be used instead.

### scrollViewToVisible(animated:margin:)

Adjusts the scroll view to make the specified view visible.

The optional `margin` parameter specifies an extra margin around the view which is also made visible. If the `margin` parameter is unspecified or `nil`, the value of `visibilityScrollMargin` will be used instead.

### scrollFirstResponderToVisible(animated:margin:)

Adjusts the scroll view to make the first responder visible. If no first responder is defined, this method has no effect.

The optional `margin` parameter specifies an extra margin around the first responder which is also made visible. If the `margin` parameter is unspecified or `nil`, the value of `visibilityScrollMargin` will be used instead.

## Caveats

### Changing the Background Color

The embedded view is positioned within the container view's safe area, and consequently, the embedded view's safe area insets are zero, and if the embedded view's background color is set, it won't extend underneath the navigation bar or status bar.

<< Screenshot >>

To specify a background color that extends to the edges of the screen:

1. Set the background color of the container view to the desired color.

    << Screenshot >> 

2. Set the embedded view's background color to transparent.

    << Screenshot >>

### Resizing the Embedded View

<< Mention calling self.parent?.view.setNeedsLayout (+ layoutIfNeeded for animation) (or scrollView.setNeedsLayout) whenever the embedded view's auto layout changes. >>

<< Example code >>

## Usage Without Subclassing

In situations where subclassing `ContainerScrollViewController` is not an option, the helper class `ContainerScrollViewEmbedder` can be used instead:

```swift
import ContainerScrollViewController

class MyEmbeddingViewController: UIViewController {

    lazy var containerScrollViewEmbedder = ContainerScrollViewEmbedder(embeddingViewController: self)

    override func viewDidLoad() {
        super.viewDidLoad()

        containerScrollViewEmbedder.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        containerScrollViewEmbedder.prepare(for: segue, sender: sender)
    }

    // Note: Only required in apps that support device orientation changes.
    override func viewWillTransition(to size: CGSize, 
            with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        containerScrollViewEmbedder.viewWillTransition(to: size, with: coordinator)
    }

}
```

The `ContainerScrollViewEmbedder` class supports all of the same [properties](#properties) and [methods](#methods) as `ContainerScrollViewController`.  

`ContainerScrollViewEmbedder` can also be used to embed a view controller programmatically, in which case the `viewDidLoad` and `prepare(for:sender:)` methods shown above should be omitted. Instead, provide a definition of `viewDidLoad` that calls `embedViewController` to embed the desired view controller:

```swift
import ContainerScrollViewController

class MyEmbeddingViewController: UIViewController {

    lazy var containerScrollViewEmbedder = ContainerScrollViewEmbedder(embeddingViewController: self)

    override func viewDidLoad() {
        super.viewDidLoad()

        let myEmbeddedViewController = MyEmbeddedViewController()
        containerScrollViewEmbedder.embedViewController(myEmbeddedViewController)
    }

    // Note: Only required in apps that support device orientation changes.
    override func viewWillTransition(to size: CGSize, 
            with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        containerScrollViewEmbedder.viewWillTransition(to: size, with: coordinator)
    }

}
```

## How It Works

<< View hierarchy >>

<< View controller hierarchy >>

<< Container view mechanism >>

<< Use of additionalSafeAreaInsets vs. content size >>

<< Keyboard resize filtering >>

See also:

* [Working with Scroll Views](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/WorkingwithScrollViews.html)

* [Managing the Keyboard](https://developer.apple.com/library/archive/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html#//apple_ref/doc/uid/TP40009542-CH5-SW3)

## Special Cases Handled

<< Correct adjustment of the scroll view's additional safe area insets when the keyboard is presented, in the case when the container view doesn't cover the entire screen, but also allowing for the possibility that `additionalSafeAreaInsets.bottom` may have already been set to compensate for an auxilliary view. >>

<< Filters out rapid sequences of changes to the height of the keyboard.
See extreme example described in BottomInsetFilter comments. >>

<< Suppresses unwanted UITextField text position animation as the focus
moves between text fields. >>

<< Pins the upper left corner of the embedded view during device rotations, while preventing out of range content offsets. >>

<< Works around an issue when the keyboard is presented and the device orientation changes, in which case, as of iOS 12, UIKit doesn't correctly scroll the first responder text field to make it visible. >>

<< Correctly handles the keyboard partially occluding a `ContainerScrollView` that doesn't completely cover the screen. >>

<< Enables `UIScrollView.alwaysBounceVertical` when the keyboard is presented if `UIScrollView.keyboardDismissMode` is set to anything other than `.none`, so the keyboard can be dismissed even if the view is too short to normally allow scrolling. >>
