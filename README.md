# LNSideMenu

[![CI Status](http://img.shields.io/travis/Luan Nguyen/LNSideMenu.svg?style=flat)](https://travis-ci.org/Luan Nguyen/LNSideMenu)
[![Version](https://img.shields.io/cocoapods/v/LNSideMenu.svg?style=flat)](http://cocoapods.org/pods/LNSideMenu)
[![License](https://img.shields.io/cocoapods/l/LNSideMenu.svg?style=flat)](http://cocoapods.org/pods/LNSideMenu)
[![Platform](https://img.shields.io/cocoapods/p/LNSideMenu.svg?style=flat)](http://cocoapods.org/pods/LNSideMenu)

A side menu based on [ENSwiftSideMenu](https://github.com/evnaz/ENSwiftSideMenu). The side menu view controller is available and it will be automatically added to Left/Right container view. This project is written in **Swift**:

![Demo](https://cloud.githubusercontent.com/assets/13121441/17393128/d1500b0e-5a4b-11e6-86fe-2029241720d0.gif)

## Usage

. Create a UINavigationController subclassing from LNSideMenuNavigationController

. Initilize the menu view with a source view:
```swift
  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    let items = ["All","Hot Food","Sandwiches","Hot Pots","Hot Rolls", "Salads","Pies","Dessrts","Drinks","Breakfast","Cookies","Lunch"]
    sideMenu = LNSideMenu(sourceView: view, menuPosition: .Left, items: items)
    // One more optional parameter is highlighItemAtIndex (Int)
    sideMenu?.delegate = self
    view.bringSubviewToFront(navigationBar)
  }
```
. Implementing delegate methods

. To change content viewcontroller use next line in your UINavigationController subclassing

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

. It has a feature for navigation bar translucent. To use this feature, just add code as below:
```swift
  self.navigationBarTranslucentStyle()
  sideMenuManager?.sideMenuController()?.sideMenu?.isNavbarHiddenOrTranslucent = true
```

. Check example project for more explaination

## Custom Properties
```
. disabled: default is false, disabled/enabled sidemenu
. bouncingEnabled: default is true, disabled/enabled dynamic animator
. Gesture recognizers: allowLeftSwipe, allowRightSwipe, allowPanGesture: default is true
. animationDuration: default is 0.5, show/hide sidemenu animation duration
. hideWhenDidSelectOnCell: default is true, the sidemenu is hidden when selecting an item on menu
. SideMenu custom colors: 
  - menuBackgroundColor: default is purpleColor
  - itemBGColor: default is whiteColor
  - highlightItemColor: default is redColor
  - itemTitleColor: default is blackColor
```

## Requirements
. Xcode 7.3
. iOS 8 or higher

## Installation

### Cocoapods

LNSideMenu is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'LNSideMenu', '~> 1.1.0'
```

### Manual

Adding all files in LNSideMenu folder to your project folder

## TODO

Custom container view controller transitions and animations.

## Author

Luan Nguyen

## License

LNSideMenu is available under the MIT license. See the LICENSE file for more info.
