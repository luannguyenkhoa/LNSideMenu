//
//  LNExtension.swift
//  LNSideMenuEffect
//
//  Created by Luan Nguyen on 6/22/16.
//  Copyright © 2016 Luan Nguyen. All rights reserved.
//

import UIKit

public protocol LNSideMenuManager {
  
  func sideMenuController() -> LNSideMenuProtocol?
  func toggleSideMenuView()
  func hideSideMenuView()
  func showSideMenuView()
  func fixSideMenuSize()
}

public struct LNSideMenuManagement: LNSideMenuManager {
  
  var viewController: UIViewController?
  public init(viewController: UIViewController) {
    self.viewController = viewController
  }
  
  /**
   Changes current state of side menu view
   */
  public func toggleSideMenuView() {
    sideMenuController()?.sideMenu?.toggleMenu()
  }
  /**
   Hides the side menu view
   */
  public func hideSideMenuView() {
    sideMenuController()?.sideMenu?.hideSideMenu()
  }
  /**
   Shows the side menu view
   */
  public func showSideMenuView() {
    sideMenuController()?.sideMenu?.showSideMenu()
  }
  /**
   REturns a Bool value indicating whether the side menu is showed
   
   - returns: Bool value
   */
  public func isSideMenuOpen() -> Bool {
    guard let sideMenu = sideMenuController()?.sideMenu else {
       return false
    }
    return sideMenu.isMenuOpen
  }
  /**
   This function should be called inside viewDidLayoutSubviews. That will helps to fix size and position of the side menu when the screen rotates
   */
  public func fixSideMenuSize() {
    if let navController = viewController?.navigationController as? LNSideMenuNavigationController {
      navController.sideMenu?.updateFrame()
    }
  }
  /**
   Returns a protocol that contains a sidemenu
   
   - returns: a viewcontroller responding to protocol
   */
  public func sideMenuController() -> LNSideMenuProtocol? {
    guard var interation: UIViewController? = viewController?.parentViewController else {
      return topMostController()
    }
    repeat {
      if interation is LNSideMenuProtocol {
        return interation as? LNSideMenuProtocol
      } else if let parentViewController = interation?.parentViewController where parentViewController != interation {
        interation = parentViewController
      } else {
        interation = nil
      }
    } while (interation != nil)
    return interation as? LNSideMenuProtocol
  }
  
  private func topMostController() -> LNSideMenuProtocol? {
    var topController = UIApplication.sharedApplication().keyWindow?.rootViewController
    if topController is UITabBarController {
      topController = (topController as! UITabBarController).selectedViewController
    }
    var lastMenuProtocol: LNSideMenuProtocol?
    while topController?.presentedViewController != nil {
      if topController?.presentedViewController is LNSideMenuProtocol  {
        lastMenuProtocol = topController?.presentedViewController as? LNSideMenuProtocol
      }
    }
    
    if let lastMenuProtocol = lastMenuProtocol {
      return lastMenuProtocol
    }
    return topController as? LNSideMenuProtocol
  }
  
}