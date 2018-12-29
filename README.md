# ContainerScrollViewController

* [Purpose](#purpose)
* [Installation](#installation)
* [Usage](#usage)
* [Properties](#properties)
* [Caveats](#caveats)
* [Usage Without Subclassing](#usage-without-subclassing)
* [How it Works](#how-it-works)
* [Special Cases Handled](#special-cases-handled)

## Purpose

A common UIKit Auto Layout task involves creating a view controller with a static layout that is too large to fit older, smaller devices, or devices in landscape orientation, or the area of the screen above the keyboard.

For example, consider the following sign up screen, which fits on an iPhone XS, but not on an iPhone SE when the keyboard is presented:

<< iPhone XS and SE screenshots, with and without the keyboard >>

It's possible to handle this case in Interface Builder by manually nesting the view inside a scroll view, as described by Apple's [Working with Scroll Views](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/WorkingwithScrollViews.html) documentation, but this approach can be awkward. According to the Medium article [How to configure a UIScrollView with Auto Layout in Interface Builder](https://medium.com/@pradeep_chauhan/how-to-configure-a-uiscrollview-with-auto-layout-in-interface-builder-218dcb4022d7), 17 steps are required.

ContainerScrollViewController makes handling this scenario easier by using Interface Builder's container view feature to embed a view controller in a scroll view. The embedded view controllers's contents can then be manipulated separately in Interface Builder.

<< Interface Builder embedding screenshot >>

ContainerScrollViewController also takes care of several tricky edge cases involving the keyboard and device rotations. 

## Installation

To install ContainerScrollViewController using CocoaPods, add the following to your Podfile:

```
pod 'ContainerScrollViewController'
```

## Usage

Subclasses of `ContainerScrollViewController` may be configured using storyboards or in code.

It's also possible to use either of these approaches without subclassing, and instead use an arbitrary view controller in conjunction with the helper class `ContainerScrollViewEmbedder`. This is described in the section [Usage Without Subclassing](#usage-without-subclassing), below.     

### Storyboards

To create a container scroll view controller and its embedded view controller in a storyboard:

1. Subclass `ContainerScrollViewController`.
2. In Interface Builder, create a new view controller and set its class to your  `ContainerScrollViewController` subclass.
3. In the outline view, delete the new view controller's view.
4. Create a new container view and drag it into the view controller, replacing the view you just deleted.
5. Set the container view's background color to anything other than transparent, which is the default value for Interface Builder's container views. Otherwise, it will appear black.

If you have an existing view controller that you'd like to embed in the container view controller instead of the embedded view controller that
Interface Builder created along with the container view, follow these additional steps:

6. Delete the view controller that Interface Builder created as the destination of the container view's embed segue.
7. Create a new embed segue from the container scroll view controller to your existing view controller.

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

The following properties of `ContainerScrollViewController` can be modified to control its behavior:

### `shouldResizeEmbeddedViewForKeyboard`

A boolean value that determines whether or not the embedded view is resized when the keyboard is presented.

* `true` - When the keyboard is presented, the embedded view shrinks to fit the portion of the scroll view not overlapped by the keyboard, to the extent that this is permitted by the embedded view's Auto Layout constraints.

* `false` - When the keyboard is presented, the embedded view's size remains unchanged. This is the default value.

### `shouldScrollFirstResponderTextFieldToVisibleForKeyboard`

A boolean value that determines whether or not the scroll view will automatically scroll to make the first responder text field visible in response to keyboard changes.

* `true` - When the keyboard is presented or changes size, for example in response to a device orientation change, the scroll view scrolls to make the first responder text field visible. This is the default value.

* `false` - No special action is taken in response to keyboard changes. Even if this is set to `false`, UIKit may scroll the text field to visible, although this may not work correctly in all cases. Use this value to override ContainerScrollViewController's default first responder text field visibility scrolling behavior.

### `scrollToVisibleMargin`

A floating point value representing a veritcal margin applied to text fields when the scroll view is automatically scrolled to make the first responder text field visible. The default value is 0, which matches the UIKit default behavior.

### `keyboardAdjustmentBehavior`

An enum representing the method used to adjust the view when the keyboard is presented. Possible values are:

* `.none` - Make no view adjustments when the keyboard is presented. If no additional action is taken, the keyboard will overlap the scroll view and its embedded view. Use this value to override ContainerScrollViewController's default keyboard handling behavior.

* `.adjustAdditionalSafeAreaInsets` - Adjust the view controller's bottom additional safe area inset. This is the default value.

* `.adjustScrollViewContentSize` - Adjust the scroll view's content size. This approach leaves the view controller's bottom additional safe area inset untouched, which may be desirable if you are using it for other purposes.

    Unfortunately, using the `.adjustScrollViewContentSize` behavior, when the keyboard is presented, at least as of iOS 12, the scroll indicator will appear misaligned when the left and right safe area insets are nonzero, for example in landscape orientation on iPhone X. This appears to be a side effect of setting `UIScrollView.scrollIndicatorInsets.bottom` to a nonzero value.

    << Screenshot >>

## Methods

<< ScrollXToVisible methods >>

## Caveats

### Changing the Background Color

The embedded view is positioned within the container view's safe area, and consequently, the embedded view's safe area insets are zero, and if the embedded view's background color is set, it won't extend underneath the navigation bar or status bar.

To specify a background color that extends to the edges of the screen:

1. Set the background color of the container view to the desired color.
2. Set the embedded view's background color to transparent.

### Resizing the Embedded View

<< Mention calling self.parent?.view.setNeedsLayout (+ layoutIfNeeded for animation) (or scrollView.setNeedsLayout) whenever the embedded view's auto layout changes. >>

<< Example code >>

## Usage Without Subclassing

<< ContainerScrollViewEmbedder supports the same properties as ContainerScrollViewController. >>

## How It Works

<< Keyboard resize filtering >>

## Special Cases Handled

<< Correct adjustment of the scroll view's additional safe area insets when the keyboard is presented, in the case when the container view doesn't cover the entire screen. >>

<< Filters out rapid sequences of changes to the height of the keyboard.
See extreme example described in BottomInsetFilter comments. >>

<< Suppresses unwanted UITextField text position animation as the focus
moves between text fields. >>

<< Pins the upper left corner of the embedded view during device rotations, while preventing out of range content offsets. >>

<< Works around an issue when the keyboard is presented and the device orientation changes, in which case, as of iOS 12, UIKit doesn't correctly scroll the text field to make it visible. >>

<< Correctly handles the keyboard partially occluding a `ContainerScrollView` that doesn't completely cover the screen. >>
