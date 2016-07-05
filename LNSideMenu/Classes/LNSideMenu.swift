//
//  LNSideMenu.swift
//  LNSideMenuEffect
//
//  Created by Luan Nguyen on 6/22/16.
//  Copyright © 2016 Luan Nguyen. All rights reserved.
//

import UIKit

public class LNSideMenu: NSObject, UIGestureRecognizerDelegate {

  public typealias Completion = () -> ()
  
  // FIXME: Should review it
  let kXPoint: CGFloat = 25
  let kPushMagnitude: CGFloat = 35
  
  // MARK: Properties
  public var menuWidth: CGFloat = UIScreen.mainScreen().bounds.size.width {
    didSet {
      needUpdateAppearance = true
      updateSideMenuApperanceIfNeeded()
      updateFrame()
    }
  }
  
  public var isNavbarHiddenOrTranslucent = false {
    didSet {
      // Refresh side menu whenever this property is set a new value
      refreshSideMenu()
    }
  }
  
  private(set) public var isMenuOpen: Bool = false
  public weak var delegate: LNSideMenuDelegate?
  public var allowLeftSwipe = true
  public var allowRightSwipe = true
  public var allowPanGesture = true
  public var animationDuration = 0.5
  public var hideWhenDidSelectOnCell = true
  public var items = [String]()
  
  // private
  private var position: Position = .Left
  private let sideMenuContainerView = UIView()
  private (set)var menuViewController: LNPanelViewController!
  private var sourceView: UIView!
  private var needUpdateAppearance = false
  private var panGesture: UIPanGestureRecognizer?
  
  public init(sourceView source: UIView, position: Position) {
    super.init()
    sourceView = source
    self.position = position
    setupMenuView()
    
    panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
    panGesture?.delegate = self
    sourceView.addGestureRecognizer(panGesture!)
    
    addGesture(position) { [unowned self] (leftSwipeGesture, rightSwipeGesture) in
        self.sourceView.addGestureRecognizer(leftSwipeGesture)
        self.sideMenuContainerView.addGestureRecognizer(rightSwipeGesture)
    }
  }
  // Initial swipe gesture with specific direction
  private func initialSwipeGesture(direction: UISwipeGestureRecognizerDirection) -> UISwipeGestureRecognizer {
    let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
    swipeGesture.delegate = self
    swipeGesture.direction = direction
    return swipeGesture
  }
  
  private func addGesture(pos: Position, handler: (UISwipeGestureRecognizer, UISwipeGestureRecognizer)->()) {
    let leftSwipeGesture = pos == .Left ? initialSwipeGesture(.Right) : initialSwipeGesture(.Left)
    let rightSwipeGesture = pos == .Left ? initialSwipeGesture(.Left) : initialSwipeGesture(.Right)
    handler(leftSwipeGesture, rightSwipeGesture)
  }
  
  public convenience init(sourceView source: UIView, menuPosition: Position, items: [String]) {
    self.init(sourceView: source, position: menuPosition)
    self.items = items
    self.menuViewController = LNPanelViewController(items: items, menuPosition: menuPosition)
    self.menuViewController.delegate = self
    sideMenuContainerView.addSubview |> self.menuViewController.view
  }
  
  internal func handlePanGesture(gesture: UIPanGestureRecognizer) {
    
    let leftToRight = gesture.velocityInView(gesture.view).x > 0
    switch gesture.state {
    case .Began:
      menuViewController.sideMenuView.killScrolling()
      break
    case .Changed:
      
      let translation = gesture.translationInView(sourceView).x
      let xpoint = sideMenuContainerView.center.x + translation + (position == .Left ? 1: -1) * menuWidth / 2
      
      if position == .Left {
        if xpoint <= 0 || xpoint > CGRectGetWidth(sideMenuContainerView.frame) {
          return
        }
      } else {
        if xpoint <= sourceView.frame.size.width - menuWidth || xpoint >= sourceView.frame.size.width {
          return
        }
      }
      sideMenuContainerView.center.x = sideMenuContainerView.center.x + translation
      gesture.setTranslation |> (CGPointZero, sourceView)
      
    default:
      let shouldClose = position == .Left ? !leftToRight && CGRectGetMaxX(sideMenuContainerView.frame) < menuWidth : leftToRight && CGRectGetMinX(sideMenuContainerView.frame) > (sourceView.frame.size.width - menuWidth)
      toggleMenu(!shouldClose)
    }
  }
  
  public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
    menuViewController.sideMenuView.killScrolling()
    if let shouldOpen = delegate?.sideMenuShouldOpenSideMenu?() where !shouldOpen {
      return false
    }
    
    if let gestureRecognizer = gestureRecognizer as? UISwipeGestureRecognizer {
      if !allowLeftSwipe && gestureRecognizer.direction == .Left {
        return false
      }
      
      if !allowRightSwipe && gestureRecognizer.direction == .Right {
        return false
      }
    } else if gestureRecognizer == panGesture {
      if !allowPanGesture {
        return false
      }
      
      let touchPosition = gestureRecognizer.locationOfTouch(0, inView: sourceView)
      if position == .Left {
        if isMenuOpen && touchPosition.x < menuWidth {
          return true
        }
        if touchPosition.x < 25 {
          return true
        }
      } else {
        if isMenuOpen && touchPosition.x > CGRectGetWidth(sourceView.frame) - menuWidth {
          return true
        }
        if touchPosition.x > CGRectGetWidth(sourceView.frame) - kXPoint {
          return true
        }
      }
      return false
    }
    return true
  }
  
  internal func handleGesture(gesture: UISwipeGestureRecognizer) {
    // Toggle side menu by swipe gesture direction
    toggleMenu((position == .Right && gesture.direction == .Left) || (position == .Left && gesture.direction == .Right))
  }
  
  private func updateSideMenuApperanceIfNeeded() {
    if needUpdateAppearance {
      sideMenuContainerView.frame.size.width = menuWidth
      sideMenuContainerView.layer.shadowPath = UIBezierPath(rect: sideMenuContainerView.bounds).CGPath
      needUpdateAppearance = false
    }
  }
  
  private func setupMenuView() {
    
    // Configure side menu container
    updateFrame()
    
    sideMenuContainerView.backgroundColor = .clearColor()
    sourceView.addSubview |> sideMenuContainerView
  }
  
  private func toggleMenu(isShow: Bool, completion: Completion? = nil) {
    
    if isShow && delegate?.sideMenuShouldOpenSideMenu?() == false {
      return
    }
    
    updateSideMenuApperanceIfNeeded()
    isMenuOpen = isShow
    let (width, height) = adjustFrameDimensions |> (CGRectGetWidth(sourceView.frame), CGRectGetHeight(sourceView.frame))
    let destFrame = position == .Left ? CGRectMake(isShow ? 0: -menuWidth, 0, menuWidth, height) :
                                        CGRectMake(isShow ? width-menuWidth : width, 0, menuWidth, height)
    UIView.animateWithDuration(animationDuration, animations: { 
      self.sideMenuContainerView.frame = destFrame
      }, completion: { _ in
        self.isMenuOpen ? self.delegate?.sideMenuDidOpen?() : self.delegate?.sideMenuDidClose?()
        if let completion = completion { completion() }
    })
    isShow ? delegate?.sideMenuWillOpen?() : delegate?.sideMenuWillClose?()
  }
  
  public func toggleMenu() {
    toggleMenu |> (!isMenuOpen, nil)
    if !isMenuOpen { updateSideMenuApperanceIfNeeded() }
  }
  
  public func hideSideMenu(completion: Completion? = nil) {
    // Just only show sidemenu if it has really hidden
    if isMenuOpen { toggleMenu |> (false, completion) }
  }
  
  public func showSideMenu() {
    // Just only show sidemenu if it has really showed
    if !isMenuOpen { toggleMenu |> (true, nil) }
  }
  
  public func refreshMenu(items: [String]) {
    // Refresh side menu with a new list items
    self.items = items
    menuViewController.sideMenuView.items = items
    menuViewController.sideMenuView.refresh()
  }
  
  public func updateFrame() {
    let (width, height) = adjustFrameDimensions |> (CGRectGetWidth(sourceView.frame), CGRectGetHeight(sourceView.frame))
    sideMenuContainerView.frame = CGRectMake(position == .Left ? isMenuOpen ? 0: -menuWidth : isMenuOpen ? width - menuWidth : width+1
      , 0, width, height)
  }
  
  private func refreshSideMenu() {
    updateFrame()
    menuViewController.isNavigationBarChanged = isNavbarHiddenOrTranslucent
  }
  
  private func adjustFrameDimensions( width: CGFloat, height: CGFloat ) -> (CGFloat,CGFloat) {
    if floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1 &&
      (UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.LandscapeRight ||
        UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.LandscapeLeft) {
      // iOS 7.1 or lower and landscape mode -> interchange width and height
      return (height, width)
    }
    return (width, height)
  }
}

extension LNSideMenu: LNSMDelegate {
  func didSelectItemAtIndex(SideMenu SideMenu: LNSideMenuView, index: Int) {
    // Hide side menu if needed
    if hideWhenDidSelectOnCell {
      hideSideMenu({ [unowned self] in
        self.delegate?.didSelectItemAtIndex(index)
      })
    } else {
      // Send back did select item at index action by delegate
      delegate?.didSelectItemAtIndex(index)
    }
  }
}

