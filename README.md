# ContainerScrollViewController

## Purpose

A common UIKit Auto Layout task involves creating a static view controller whose contents happen to be too large to fit on older, smaller devices, or in landscape orientation, or when the keyboard is presented.

For example, consider the following sign up screen, which fits on an iPhone XS, but not on an iPhone SE when the keyboard is presented:

<< iPhone XS and SE screenshots, with and without the keyboard >>

It's possible to handle this case in Interface Builder by manually nesting the view inside a scroll view, as described in [Working with Scroll Views](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/WorkingwithScrollViews.html), but this approach can be awkward. According to [How to configure a UIScrollView with Auto Layout in Interface Builder](https://medium.com/@pradeep_chauhan/how-to-configure-a-uiscrollview-with-auto-layout-in-interface-builder-218dcb4022d7), 17 steps are required.

ContainerScrollViewController makes handling this case easier by leveraging Interface Builder's container view feature to embed a view controller in a scroll view. The embedded view controllers's contents can then be manipulated separately in Interface Builder.

<< Interface Builder embedding screenshot >>

ContainerScrollViewController also handles the case when the virtual keyboard overlaps the scroll view. This can be hard to implement well.

## Installation

To install ContainerScrollViewController using CocoaPods, add the following to your Podfile:

```
pod 'ContainerScrollViewController'
```

## Usage

Subclasses of `ContainerScrollViewController` may be configured using storyboards or entirely in code.

It's also possible to use either of these approaches without subclassing, but instead using an arbitrary view controller in conjunction with the `ContainerScrollViewEmbedder` class, which is described later.     

### Storyboards

To create an container scroll view controller and an embedded view controller in a storyboard, follow these steps:

1. In Interface Builder, create a new view controller and set its class to a subclass of `ContainerScrollViewController`.

2. In the outline view, delete the new view controller's view.

3. Drag a container view into the view controller.

4. Set the container view's background color to anything other than transparent, which is its default value. Otherwise, it will appear black.

If you have an existing view controller that you'd like to embed in the container view controller instead of the embedded view controller that
Interface Builder created along with the container view, follow these additional steps:

5. Delete the view controller that is the destination of the container view's embed segue.

6. Connect the container view controller  to another view controller with a new embed segue.

### Code

To integrate `ContainerScrollViewController` programmatically, follow these steps:

1. Subclass `ContainerScrollViewController`.

2. In `viewDidLoad`, call `embedViewController`, passing it the view controller you'd like to embed in the container view controller's scroll view.

### Auto Layout Considerations

**IMPORTANT** - For ContainerScrollViewController to determine the height of the scroll view's content, the embedded view must contain an unbroken chain of constraints and views stretching from the content view’s top edge to its bottom edge. This is also true for the embedded view's width. 

If this is not the case, the embedded view will not scroll correctly. 

The easiest way to do this while avoiding Auto Layout constraint errors is to create a bottom alignment constraint with a priority of 249.

<< Screenshot >>

### Large View Controllers

To make the embedded view controller larger than the height of the screen, change its simulated size to Freeform and adjust the view's size.

<< Screenshot >>

## Options

## Caveats

The embedded view is positioned within the container view's safe area, and consequently, the embedded view's safe area insets are zero, and if the embedded view's background color is set, it won't extend underneath the navigation bar or status bar.

To specify a background color that extends to the edges of the screen:
1. Set the background color of the container view to the desired color.
2. Set the embedded view's background color to transparent or to
the same color as the container view's background.

<< Mention calling self.parent?.view.setNeedsLayout (+ layoutIfNeeded for animation) whenever the embedded view's auto layout changes. >>

## Usage Without Subclassing

## How It Works

## Design Considerations

<< Use of adjusted safe area insets vs. other approaches. >>

## Special Cases Handled

* Correct adjustment of the scroll view's additional safe area insets when the keyboard is presented, in the case when the container view doesn't cover the entire screen.

* Filters out rapid sequences of changes to the height of the keyboard.
See extreme example described in BottomInsetFilter comments.

* Suppresses unwanted UITextField text position animation as the focus
moves between text fields.
