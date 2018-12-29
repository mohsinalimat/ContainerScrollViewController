# ContainerScrollViewController

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

It's possible to handle this case in Interface Builder by manually nesting the view inside a scroll view, as described in Apple's [Working with Scroll Views](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/WorkingwithScrollViews.html), but this approach can be awkward. According to the Medium article [How to configure a UIScrollView with Auto Layout in Interface Builder](https://medium.com/@pradeep_chauhan/how-to-configure-a-uiscrollview-with-auto-layout-in-interface-builder-218dcb4022d7), 17 steps are required.

ContainerScrollViewController makes handling this scenario easier by using Interface Builder's container view feature to embed a view controller in a scroll view. The embedded view controllers's contents can then be manipulated separately in Interface Builder.

<< Interface Builder embedding screenshot >>

ContainerScrollViewController also handles the case when the keyboard overlaps the scroll view.

## Installation

To install ContainerScrollViewController using CocoaPods, add the following to your Podfile:

```
pod 'ContainerScrollViewController'
```

## Usage

Subclasses of `ContainerScrollViewController` may be configured using storyboards or in code.

It's also possible to use either of these approaches without subclassing, and instead use an arbitrary view controller in conjunction with the helper class `ContainerScrollViewEmbedder`. This is described in [Usage Without Subclassing](#usage-without-subclassing), below.     

### Storyboards

To create a container scroll view controller and its embedded view controller in a storyboard:

1. Subclass `ContainerScrollViewController`.
2. In Interface Builder, create a new view controller and set its class to your  `ContainerScrollViewController` subclass.
3. In the outline view, delete the new view controller's view.
4. Create a new container view and drag it into the view controller.
5. Set the container view's background color to anything other than transparent, which is the default value. Otherwise, it will appear black.

If you have an existing view controller that you'd like to embed in the container view controller instead of the embedded view controller that
Interface Builder created along with the container view, follow these additional steps:

6. Delete the view controller that is the destination of the container view's embed segue.
7. Create a new embed segue, connecting the container view controller to your existing view controller.

### Code

To integrate `ContainerScrollViewController` programmatically:

1. Subclass `ContainerScrollViewController`.
2. In `viewDidLoad`, call `embedViewController` with the view controller you'd like to embed in the container view controller's scroll view.

### Auto Layout Considerations

**IMPORTANT** - For ContainerScrollViewController to determine the height of the scroll view's content, the embedded view must contain an unbroken chain of constraints and views stretching from the content view’s top edge to its bottom edge. This is also true for the embedded view's width. 

If this is not the case, the embedded view will not scroll correctly. 

The easiest way to do this while avoiding Auto Layout constraint errors is to create a bottom alignment constraint with a low priority (below 250).

<< Screenshot >>

### Large View Controllers

To make the embedded view controller larger than the height of the screen, change its simulated size to Freeform and adjust the view's size.

<< Screenshot >>

## Properties

The following properties of `ContainerScrollViewController` can be modified to control its behavior:

**`shouldResizeEmbeddedViewForKeyboard`**

<p style="margin-left: 2em;">
If <code>true</code>, when the keyboard is presented, the embedded view will shrink to fit the portion of the scroll view not overlapped by the keyboard, to the extent that this is permitted by the embedded view's Auto Layout constraints.
</p>

<p style="margin-left: 2em;">
If <code>false</code>, when the keyboard is presented, the embedded view's size will remain unchanged. This is the default value.
</p>

**`keyboardAdjustmentBehavior`**

<p style="margin-left: 2em;">
The behavior for adjusting the view when the keyboard is presented. Possible values are:
</p>

<div style="margin-left: 4em; text-indent: -2em;">

`.none` - Make no view adjustments when the keyboard is presented. If no additional action is taken, the keyboard will overlap the scroll view and its embedded view. Use this value to override ContainerScrollViewController's default keyboard handling behavior.

`.adjustAdditionalSafeAreaInsets` - Adjust the view controller's bottom additional safe area inset. This is the default value.

`.adjustScrollViewContentSize` - Adjust the scroll view's content size. This approach leaves the view controller's bottom additional safe area inset untouched, which may be desirable if you are using it for other purposes. However, it will result in misaligned scroll indicators when the left and right safe area insets are nonzero, for example in landscape orientation on iPhone X. At least as of iOS 12, this appears to be a side effect of setting `UIScrollView.scrollIndicatorInsets.bottom` to a nonzero value.

</div>

## Caveats

### Changing the Background Color

The embedded view is positioned within the container view's safe area, and consequently, the embedded view's safe area insets are zero, and if the embedded view's background color is set, it won't extend underneath the navigation bar or status bar.

To specify a background color that extends to the edges of the screen:

1. Set the background color of the container view to the desired color.
2. Set the embedded view's background color to transparent.

### Resizing the Embedded View

<< Mention calling self.parent?.view.setNeedsLayout (+ layoutIfNeeded for animation) whenever the embedded view's auto layout changes. >>

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
