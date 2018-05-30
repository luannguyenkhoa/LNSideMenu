# LNSideMenu

[![CI Status](http://img.shields.io/travis/Luan Nguyen/LNSideMenu.svg?style=flat)](https://travis-ci.org/Luan Nguyen/LNSideMenu)
[![Version](https://img.shields.io/cocoapods/v/LNSideMenu.svg?style=flat)](http://cocoapods.org/pods/LNSideMenu)
[![License](https://img.shields.io/cocoapods/l/LNSideMenu.svg?style=flat)](http://cocoapods.org/pods/LNSideMenu)
[![Platform](https://img.shields.io/cocoapods/p/LNSideMenu.svg?style=flat)](http://cocoapods.org/pods/LNSideMenu)

SideMenu library that such as a lot of sidemenu libraries on Github for iOS. 
Besides of basic functions of a SideMenu, there is an enhancement sidemenu that was implemented some effects and animations like scrolling effect, fade animation for displaying the menu's items,..
Checking it out and enjoying.

![Demo](https://cloud.githubusercontent.com/assets/13121441/19177073/0ca0ce0e-8c70-11e6-9e12-d67e7947d98d.gif)
![Demo](https://cloud.githubusercontent.com/assets/13121441/19177074/0cd3415e-8c70-11e6-8082-5057bf406e42.gif)

## Usage

. Create a UINavigationController subclassed from LNSideMenuNavigationController in order.

. Initilize the menu view based on a source view:
```swift
func initialSideMenu(_ position: Position) {
    sideMenu = LNSideMenu(sourceView: view, menuPosition: position, items: items!)
    sideMenu?.menuViewController?.menuBgColor = UIColor.black.withAlphaComponent(0.85)
    sideMenu?.delegate = self
    // Bring navigationBar to front if needed
    view.bringSubview(toFront: navigationBar)
}
```
. Implementing delegate methods: didSelectItemAtIndex,..

. In order to change the content viewcontroller: from the your UINavigationController subclass, getting your destination and then making it as the content viewcontroller.

```swift
func didSelectItemAtIndex(index: Int) {
// TODO: Get your destViewController here
self.setContentViewController(destViewController)
}
```

. Toggle menu:

```swift
self.sideMenuManager?.toggleSideMenuView()
```

. Making navigation bar translucent by adding these code as following:
```swift
self.navigationBarTranslucentStyle()
sideMenuManager?.sideMenuController()?.sideMenu?.isNavbarHiddenOrTransparent = true
```

. Digging `Example` for more explaination

## Using your own menu

Initialize sidemenu as below in NavigationController subclass:
In order for customizing the menu size in width, we can use one of 4 types of size that consists of full, half, twothird and custom(CGFloat).
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
 
## Customizable Properties
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

. Swift 3/4


## Installation

### Cocoapods

LNSideMenu is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

Swift 3
```ruby
pod 'LNSideMenu', '~> 2.3'
```

Swift 4
```ruby
pod 'LNSideMenu', '~> 3.0'
```

### Manual

Adding all files in LNSideMenu folder to your project folder

## TODO

. Changing content viewcontroller animation

## Contribution

I will be much appreciated if anyone's interested in and take your time to contribute it.

## Author

Luan Nguyen

## License

LNSideMenu is available under the MIT license. See the LICENSE file for more info.
