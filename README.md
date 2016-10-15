# LNSideMenu

[![CI Status](http://img.shields.io/travis/Luan Nguyen/LNSideMenu.svg?style=flat)](https://travis-ci.org/Luan Nguyen/LNSideMenu)
[![Version](https://img.shields.io/cocoapods/v/LNSideMenu.svg?style=flat)](http://cocoapods.org/pods/LNSideMenu)
[![License](https://img.shields.io/cocoapods/l/LNSideMenu.svg?style=flat)](http://cocoapods.org/pods/LNSideMenu)
[![Platform](https://img.shields.io/cocoapods/p/LNSideMenu.svg?style=flat)](http://cocoapods.org/pods/LNSideMenu)

SideMenu library that such as a lot of sidemenu libraries on Github for iOS. The main feature of this library: there has a custom menu view that automatically attached as a default menu, but you can use your own menu instead. That menu view was implemented many effects and animations like scrolling effect, fade animation for displaying the menu's items,..
Check it out and explore what it can do.

![Demo](https://cloud.githubusercontent.com/assets/13121441/19177073/0ca0ce0e-8c70-11e6-9e12-d67e7947d98d.gif)
![Demo](https://cloud.githubusercontent.com/assets/13121441/19177074/0cd3415e-8c70-11e6-8082-5057bf406e42.gif)

## Usage

. Create a UINavigationController subclassing from LNSideMenuNavigationController

. Initilize the menu view with a source view:
```swift
func initialSideMenu(_ position: Position) {
    sideMenu = LNSideMenu(sourceView: view, menuPosition: position, items: items!)
    sideMenu?.menuViewController?.menuBgColor = UIColor.black.withAlphaComponent(0.85)
    sideMenu?.delegate = self
    // Bring navigationBar to front if you want
    view.bringSubview(toFront: navigationBar)
}
```
. Implementing delegate methods: didSelectItemAtIndex,..

. In order to change the content viewcontroller: from the your UINavigationController subclassing, getting your destination and then set it as the content viewcontroller.

```swift
func didSelectItemAtIndex(index: Int) {
// TODO: Get your destViewController in here
self.setContentViewController(destViewController)
}
```

. Toggle menu:

```swift
self.sideMenuManager?.toggleSideMenuView()
```

. It has a feature for navigation bar translucent. In order to using this feature, just add code as below:
```swift
self.navigationBarTranslucentStyle()
sideMenuManager?.sideMenuController()?.sideMenu?.isNavbarHiddenOrTransparent = true
```

. Check example project for more explaination

## Using your own menu

Initialize side menu using function 
```swift 
func initialCustomMenu(pos position: Position) {
    let menu = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LeftMenuTableViewController") as! LeftMenuTableViewController
    menu.delegate = self
    sideMenu = LNSideMenu(sourceView: view, menuPosition: position, customSideMenu: menu)
    sideMenu?.delegate = self
    // Enable dynamic animator
    sideMenu?.enableDynamic = true
    // Moving down the menu view under navigation bar
    sideMenu?.underNavigationBar = true
}
``` 
in NavigationController subclassing.

There is an argument of this method with default value called ``size``, which is LNSize enum used to set the menu size consits of 3 options: full, half, twothird.

## Custom Properties
```
. disabled: default is false, disabled/enabled sidemenu
. enableDynamic: default is true, disabled/enabled dynamic animator
. enableAnimation: default is true, showing side menu with fade animation
. Gesture recognizers: allowLeftSwipe, allowRightSwipe, allowPanGesture: default is true
. animationDuration: default is 0.5, show/hide sidemenu animation duration
. hideWhenDidSelectOnCell: default is true, the sidemenu is hidden when selecting an item on menu
. SideMenu custom colors: 
- menuBgColor: default is purpleColor
- itemBgColor: default is whiteColor
- highlightColor: default is redColor
- titleColor: item title color, default is blackColor
```

## Requirements
. Xcode 8

. iOS 8 or higher

. Swift 3

## Installation

### Cocoapods

LNSideMenu is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'LNSideMenu', '~> 2.2'
```

### Manual

Adding all files in LNSideMenu folder to your project folder

## TODO

. Changing content viewcontroller animation

## Contribution

I will be happy if anyone's interested in and take the time to contribute it.

## Author

Luan Nguyen

## License

LNSideMenu is available under the MIT license. See the LICENSE file for more info.
