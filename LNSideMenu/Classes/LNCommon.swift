//
//  LNCommon.swift
//  LNSideMenuEffect
//
//  Created by Luan Nguyen on 6/22/16.
//  Copyright © 2016 Luan Nguyen. All rights reserved.
//

import UIKit
import ObjectiveC

// MARK: Global variables
internal let screenHeight = UIScreen.main.bounds.height
internal let screenWidth = UIScreen.main.bounds.width
internal let navigationBarHeight: CGFloat = 64
internal let kDistanceItemToRight: CGFloat = 18

// MARK: Typealias
internal typealias Completion = () -> ()

// MARK: Enums
public enum Position {
  case right
  case left
}

public enum LNSideMenuAnimation {
  case none
  case `default`
}

public enum LNSize {
  
  case full
  case half
  case twothird
  
  public var width: CGFloat {
    switch self {
    case .full:
      return UIScreen.main.bounds.width
    case .twothird:
      return UIScreen.main.bounds.width * 2 / 3
    case .half:
      return UIScreen.main.bounds.width / 2
    }
  }
}

public enum LNColor {
  
  case highlight
  case title
  case bgItem
  case bgView
  
  public var color: UIColor {
    switch self {
    case .highlight:
      return .red
    case .title:
      return .black
    case .bgItem:
      return .white
    case .bgView:
      return .purple
    }
  }
}

// MARK: Protocols

public protocol LNSideMenuProtocol {
  var sideMenu: LNSideMenu?{get}
  var sideMenuAnimationType: LNSideMenuAnimation {get set}
  func setContentViewController(_ contentViewController: UIViewController)
}

internal protocol LNSMDelegate: class {
  func didSelectItemAtIndex(SideMenu: LNSideMenuView, index: Int)
}

@objc public protocol LNSideMenuDelegate {
  @objc optional func sideMenuWillOpen()
  @objc optional func sideMenuWillClose()
  @objc optional func sideMenuDidOpen()
  @objc optional func sideMenuDidClose()
  @objc optional func sideMenuShouldOpenSideMenu () -> Bool
  func didSelectItemAtIndex(_ index: Int)
}

public protocol LNSideMenuManager {
  
  mutating func sideMenuController()-> LNSideMenuProtocol?
  mutating func toggleSideMenuView()
  mutating func hideSideMenuView()
  mutating func showSideMenuView()
  func fixSideMenuSize()
}

// MARK: Extensions
var sideMenuMg: LNSideMenuManagement = LNSideMenuManagement()

public extension UIViewController {
  // A protocol as a store property
  public var sideMenuManager: LNSideMenuManager? {
    get {
      sideMenuMg.viewController = self
      return sideMenuMg
    }
    set { }
  }
  
  // MARK: Navigation bar translucent style
  public func navigationBarTranslucentStyle() {
    navigationBarEffect |> true
  }
  
  public func navigationBarNonTranslecentStyle() {
    navigationBarEffect |> false
  }
  
  fileprivate func navigationBarEffect(_ translucent: Bool) {
    navigationController?.navigationBar.isTranslucent = translucent
    navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .top, barMetrics: .default)
    navigationController?.navigationBar.shadowImage = UIImage()
  }
}

// MARK: Operator overloading
infix operator |>: AdditionPrecedence

internal func |> <A>(arg: inout A, param: A) {
  arg = param
}

internal func |><A, B> (f: (A)->B, arg: A) -> B {
  return f(arg)
}

internal func |> <A, B, C> (f: @escaping (A)-> B, g: @escaping (B)->C) -> (A) -> C {
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

// A functional that handling mathematic method
internal func inoutMath<A>(_ f: (_ lhs: inout A, _ rhs: A) -> (), _ fParam: inout A, _ sParam: A) {
  f(&fParam, sParam)
}

internal func compare<A>(_ f:(_ lhs: A, _ rhs: A) -> Bool, _ fp: inout A, _ sp: A) {
  fp = f(fp, sp) ? sp : fp
}

// Getting frame's components
extension CGRect {
  
  var x: CGFloat {
    get { return self.origin.x }
    set { self.origin.x = newValue }
  }
  
  var y: CGFloat {
    get { return self.origin.y }
    set { self.origin.y = newValue }
  }
  
  var width: CGFloat {
    get { return self.size.width }
    set { self.size.width = newValue }
  }
  
  var height: CGFloat {
    get { return self.size.height }
    set { self.size.height = newValue }
  }
}

extension UIView {
  
  var x: CGFloat {
    get { return self.frame.x }
    set { self.frame.x = newValue }
  }
  
  var y: CGFloat {
    get { return self.frame.y }
    set { self.frame.y = newValue }
  }
  
  var width: CGFloat {
    get { return self.frame.width }
    set { self.frame.width = newValue }
  }
  
  var height: CGFloat {
    get { return self.frame.height }
    set { self.frame.height = newValue }
  }
  
}
