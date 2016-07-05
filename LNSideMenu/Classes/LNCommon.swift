//
//  LNCommon.swift
//  LNSideMenuEffect
//
//  Created by Luan Nguyen on 6/22/16.
//  Copyright © 2016 Luan Nguyen. All rights reserved.
//

import UIKit

// MARK: Global variables
internal let screenHeight = UIScreen.mainScreen().bounds.size.height
internal let screenWidth = UIScreen.mainScreen().bounds.size.width
internal let navigationBarHeight: CGFloat = 64

// MARK: Enums
public enum Position {
  case Right
  case Left
}

public enum LNSideMenuAnimation {
  case None
  case Default
}

public enum LNDefaultColor {
  
  case HighlightItem
  case ItemTitleColor
  case ItemBackgroundColor
  case BackgroundColor
  
  public func color() -> UIColor {
    switch self {
    case .HighlightItem:
      return .redColor()
    case .ItemTitleColor:
      return .blackColor()
    case .ItemBackgroundColor:
      return .whiteColor()
    case .BackgroundColor:
      return .purpleColor()
    }
  }
}

// MARK: Protocols

public protocol LNSideMenuProtocol {
  var sideMenu: LNSideMenu?{get}
  var sideMenuAnimationType: LNSideMenuAnimation {get set}
  func setContentViewController(contentViewController: UIViewController)
}

internal protocol LNSMDelegate: class {
  func didSelectItemAtIndex(SideMenu SideMenu: LNSideMenuView, index: Int)
}

@objc public protocol LNSideMenuDelegate {
  optional func sideMenuWillOpen()
  optional func sideMenuWillClose()
  optional func sideMenuDidOpen()
  optional func sideMenuDidClose()
  optional func sideMenuShouldOpenSideMenu () -> Bool
  func didSelectItemAtIndex(index: Int)
}

// MARK: Extensions
public extension UIViewController {
  // A protocol as a store property
  public var sideMenuManager: LNSideMenuManager? {
    get { return LNSideMenuManagement(viewController: self) }
    set {}
  }
  // MARK: Navigation bar translucent style
  public func navigationBarTranslucentStyle() {
    navigationBarEffect |> true
  }
  
  public func navigationBarNonTranslecentStyle() {
    navigationBarEffect |> false
  }
  
  private func navigationBarEffect(translucent: Bool) {
    navigationController?.navigationBar.translucent = translucent
    navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Top, barMetrics: .Default)
    navigationController?.navigationBar.shadowImage = UIImage()
  }
}

// MARK: Operator overloading
infix operator |> {associativity left}

internal func |> <A>(inout arg: A, param: A) {
  arg = param
}

internal func |><A, B> (f: A->B, arg: A) -> B {
  return f(arg)
}

internal func |> <A, B, C> (f: A-> B, g: B->C) -> A -> C {
  return { g(f($0)) }
}

internal func |><A> (f: (A)->(), arg: A){
  f(arg)
}

internal func |><A, B> (f: (A, B)->(), arg: (A, B)){
  f(arg.0, arg.1)
}

internal func |><A, B, C> (f: (A, B, C)->(), arg: (A, B, C)){
  f(arg.0, arg.1, arg.2)
}

internal func |><A, B, C, D> (f: (A, B, C, D)->(), arg: (A, B, C, D)){
  f(arg.0, arg.1, arg.2, arg.3)
}

internal func |><A, B, C, D, E> (f: (A, B, C, D, E)->(), arg: (A, B, C, D, E)){
  f(arg.0, arg.1, arg.2, arg.3, arg.4)
}

internal func |><A, B, C, D, E, F> (f: (A, B, C, D, E, F)->(), arg: (A, B, C, D, E, F)){
  f(arg.0, arg.1, arg.2, arg.3, arg.4, arg.5)
}

internal func |><A, B, C, D, E, F, G> (f: (A, B, C, D, E, F, G)->(), arg: (A, B, C, D, E, F, G)){
  f(arg.0, arg.1, arg.2, arg.3, arg.4, arg.5, arg.6)
}

internal func |><A, B, C, D, E, F, G, H> (f: (A, B, C, D, E, F, G, H)->(), arg: (A, B, C, D, E, F, G, H)){
  f(arg.0, arg.1, arg.2, arg.3, arg.4, arg.5, arg.6, arg.7)
}

internal func |><A, B, C, D, E, F, G, H, I> (f: (A, B, C, D, E, F, G, H, I)->(), arg: (A, B, C, D, E, F, G, H, I)){
  f(arg.0, arg.1, arg.2, arg.3, arg.4, arg.5, arg.6, arg.7, arg.8)
}

internal func |><A, B, C, D, E, F, G, H, I, J> (f: (A, B, C, D, E, F, G, H, I, J)->(), arg: (A, B, C, D, E, F, G, H, I, J)){
  f(arg.0, arg.1, arg.2, arg.3, arg.4, arg.5, arg.6, arg.7, arg.8, arg.9)
}






