# LNSideMenu

[![CI Status](http://img.shields.io/travis/Luan Nguyen/LNSideMenu.svg?style=flat)](https://travis-ci.org/Luan Nguyen/LNSideMenu)
[![Version](https://img.shields.io/cocoapods/v/LNSideMenu.svg?style=flat)](http://cocoapods.org/pods/LNSideMenu)
[![License](https://img.shields.io/cocoapods/l/LNSideMenu.svg?style=flat)](http://cocoapods.org/pods/LNSideMenu)
[![Platform](https://img.shields.io/cocoapods/p/LNSideMenu.svg?style=flat)](http://cocoapods.org/pods/LNSideMenu)

This one is basically similiar to a lot of ones on Github for iOS, but besides of must-have features, it supilies an interesting one focusing on effects and animations like scrolling effect, faded animation for the appearance of the menu's items,..
Let's explore and enjoy it.

![Demo](https://cloud.githubusercontent.com/assets/13121441/19177073/0ca0ce0e-8c70-11e6-9e12-d67e7947d98d.gif)
![Demo](https://cloud.githubusercontent.com/assets/13121441/19177074/0cd3415e-8c70-11e6-8082-5057bf406e42.gif)

## Get Started

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

. In order to change the content viewcontroller: from the your UINavigationController subclass, get the destination and set it as the content viewcontroller.

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

. Digging up `Example` to get a comprehensive view. 

## Take your own menu

Initialize sidemenu as below in NavigationController subclass:
The lib's currently providing 4 types of adjustable size, particularly in full, half, twothird and custom(CGFloat).
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
 
## Configurable Properties
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
