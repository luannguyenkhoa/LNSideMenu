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
  let kDBXPoint: CGFloat = 10
  let kGestureXPoint: CGFloat = 25
  let kPushMagnitude: CGFloat = 15
  let kGravityDirection: CGFloat = 3.5
  
  // MARK: Properties
  // This property should be private for this release
  private var menuWidth: CGFloat = UIScreen.mainScreen().bounds.size.width {
    didSet {
      // Update sidemenu frame and something else, whenever menuWidth property gets a new value
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
  // uidynamic behavior, set false to disable it
  public var boucingEnabled: Bool = true {
    didSet {
      cacheIsBoucingEnabled = boucingEnabled
    }
  }
  public var disabled: Bool = false
  
  // private
  private(set) public var position: Position = .Left
  private let sideMenuContainerView = UIView()
  private(set) public var menuViewController: LNPanelViewController!
  private var sourceView: UIView!
  private var needUpdateAppearance = false
  private var panGesture: UIPanGestureRecognizer?
  private var animator: UIDynamicAnimator!
  private var isGesture: Bool = false
  private var cacheIsBoucingEnabled: Bool = true
  private var dynamicAnimatorEnded: Bool = true
  private let dispatch_group: dispatch_group_t = dispatch_group_create()
  
  public init(sourceView source: UIView, position: Position) {
    super.init()
    sourceView = source
    self.position = position
    setupMenuView()
    
    /*
     A dynamic animator provides physics-related capabilities and animations for its dynamic items, and provides the context for those animations. 
     It does this by intermediating between the underlying iOS physics engine and dynamic items, via behavior objects you add to the animator.
     
     For more details: https://developer.apple.com/reference/uikit/uidynamicanimator
     */
    animator = UIDynamicAnimator(referenceView: sourceView)
    animator.delegate = self
    
    /*
     UIPanGestureRecognizer is a concrete subclass of UIGestureRecognizer that looks for panning (dragging) gestures. 
     The user must be pressing one or more fingers on a view while they pan it. 
     Clients implementing the action method for this gesture recognizer can ask it for the current translation and velocity of the gesture.
     
     For more details: https://developer.apple.com/reference/uikit/uipangesturerecognizer
     */
    panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
    panGesture?.delegate = self
    sourceView.addGestureRecognizer(panGesture!)
    
    // Adding pan gesture recognizer into source view along with handler closure
    // This is good approach for functional
    addGesture(position) { [unowned self] (leftSwipeGesture, rightSwipeGesture) in
      self.sourceView.addGestureRecognizer(leftSwipeGesture)
      self.sideMenuContainerView.addGestureRecognizer(rightSwipeGesture)
    }
  }
  // Initial swipe gesture with specific direction
  private func initialSwipeGesture(direction: UISwipeGestureRecognizerDirection) -> UISwipeGestureRecognizer {
    // Initial swipe gesture recognizer with inputting direction
    /*
     UISwipeGestureRecognizer is a concrete subclass of UIGestureRecognizer that looks for swiping gestures in one or more directions. 
     A swipe is a discrete gesture, and thus the associated action message is sent only once per gesture.
     
     For more details: https://developer.apple.com/reference/uikit/uiswipegesturerecognizer
     */
    let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
    swipeGesture.delegate = self
    swipeGesture.direction = direction
    return swipeGesture
  }
  
  private func addGesture(pos: Position, handler: (UISwipeGestureRecognizer, UISwipeGestureRecognizer)->()) {
    // Register swipeGestures with its direction based on the inputting menu position
    let leftSwipeGesture = pos == .Left ? initialSwipeGesture(.Right) : initialSwipeGesture(.Left)
    let rightSwipeGesture = pos == .Left ? initialSwipeGesture(.Left) : initialSwipeGesture(.Right)
    handler(leftSwipeGesture, rightSwipeGesture)
  }
  
  public convenience init(sourceView source: UIView, menuPosition: Position, items: [String], highlightItemAtIndex: Int = Int.max) {
    self.init(sourceView: source, position: menuPosition)
    self.items = items
    // Initial panel viewcontroller that is considered as a side menu viewcontroller
    self.menuViewController = LNPanelViewController(items: items, menuPosition: menuPosition, highlightCellAtIndex: highlightItemAtIndex)
    self.menuViewController.delegate = self
    sideMenuContainerView.addSubview |> self.menuViewController.view
  }
  
  internal func handlePanGesture(gesture: UIPanGestureRecognizer) {
    
    let leftToRight = gesture.velocityInView(gesture.view).x > 0
    switch gesture.state {
    case .Began:
      // Always kill scrolling whenever pan gesture is being started
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
      // Disable dynamic behavior effect if there is handling the gesture recognizer action
      cacheIsBoucingEnabled = false
      toggleMenu(!shouldClose)
    }
  }
  
  public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
    // Disable gesture if dynamic animator has not ended animation yet
    if !dynamicAnimatorEnded {
      return false
    }
    // Such as pan gesture, kill menu scrolling whenever user swipes on view
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
        if touchPosition.x < kGestureXPoint {
          return true
        }
      } else {
        if isMenuOpen && touchPosition.x > CGRectGetWidth(sourceView.frame) - menuWidth {
          return true
        }
        if touchPosition.x > CGRectGetWidth(sourceView.frame) - kGestureXPoint {
          return true
        }
      }
      return false
    }
    return true
  }
  
  internal func handleGesture(gesture: UISwipeGestureRecognizer) {
    // Toggle side menu by swipe gesture direction
    cacheIsBoucingEnabled = false
    toggleMenu((position == .Right && gesture.direction == .Left) || (position == .Left && gesture.direction == .Right))
  }
  
  private func updateSideMenuApperanceIfNeeded() {
    // Update sidemune appearance if needed, it means if there has a change of any related view frame that might effects
    // the sidemenu frame, we must update the sidemenu containerview frame and layer.
    if needUpdateAppearance {
      sideMenuContainerView.frame.size.width = menuWidth
      sideMenuContainerView.layer.shadowPath = UIBezierPath(rect: sideMenuContainerView.bounds).CGPath
      needUpdateAppearance = false
    }
  }
  
  private func setupMenuView() {
    
    // Configure side menu container frame
    updateFrame()
    
    // Setup container view
    sideMenuContainerView.backgroundColor = .clearColor()
    sourceView.addSubview |> sideMenuContainerView
  }
  
  private func toggleMenu(isShow: Bool, completion: Completion? = nil) {
    // Do nothing if the menu was disabled
    if disabled || !dynamicAnimatorEnded { return }
    // Do nothing if the expected
    if isShow && delegate?.sideMenuShouldOpenSideMenu?() == false {
      return
    }
    // Should update if needed
    updateSideMenuApperanceIfNeeded()
    isMenuOpen = isShow
    let (width, height) = adjustFrameDimensions |> (CGRectGetWidth(sourceView.frame), CGRectGetHeight(sourceView.frame))
    // Check it before performing animation
    if cacheIsBoucingEnabled {
      // Change ended anymator flag to false before starting dynamic animator
      dynamicAnimatorEnded = false
      // Delegate sidemenu will open/close
      isShow ? delegate?.sideMenuWillOpen?() : delegate?.sideMenuWillClose?()
      // If bouncing enabled is true, performing dynamic behavior instead of standard animation
      dynamicBehavior(isShow, width: width, height: height)
      return
    }
    
    // Calculating destination sidemenu frame based on the menu position and isShow param
    let destFrame = position == .Left ? CGRectMake(isShow ? 0: -menuWidth, 0, menuWidth, height) :
      CGRectMake(isShow ? width-menuWidth : width, 0, menuWidth, height)
    // Performing a standard animation
    UIView.animateWithDuration(animationDuration, animations: {
      self.sideMenuContainerView.frame = destFrame
      }, completion: { _ in
        self.isMenuOpen ? self.delegate?.sideMenuDidOpen?() : self.delegate?.sideMenuDidClose?()
        if let completion = completion { completion() }
    })
    isShow ? delegate?.sideMenuWillOpen?() : delegate?.sideMenuWillClose?()
  }
  
  private func dynamicBehavior(shouldOpen: Bool, width: CGFloat, height: CGFloat) {
    
    // Once this function is called then we must clean up UIDynamicAnimator object
    animator.removeAllBehaviors()
    
    var gravityDirectionX: CGFloat
    var pushMagnitude: CGFloat
    var boundaryPointX: CGFloat
    var boundaryPointY: CGFloat
    
    if (position == .Left) {
      // Left side menu
      gravityDirectionX = (shouldOpen) ? kGravityDirection : -kGravityDirection
      pushMagnitude = (shouldOpen) ? kPushMagnitude : -kPushMagnitude
      boundaryPointX = (shouldOpen) ? menuWidth : -menuWidth-2
      boundaryPointY = kDBXPoint
    }
    else {
      // Right side menu
      gravityDirectionX = (shouldOpen) ? -kGravityDirection : kGravityDirection
      pushMagnitude = (shouldOpen) ? -kPushMagnitude : kPushMagnitude
      boundaryPointX = (shouldOpen) ? width-menuWidth : width+menuWidth+2
      boundaryPointY =  -kDBXPoint
    }
    /*
     A UIGravityBehavior object applies a gravity-like force to all of its associated dynamic items. The magnitude and direction of the gravity force are configurable and are applied equally to all associated items. Use this behavior to modify the position of views and other dynamic items in your app’s interface.
     Refer to https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIGravityBehavior_Class/ for more details
    */
    let gravityBehavior = UIGravityBehavior(items: [sideMenuContainerView])
    gravityBehavior.gravityDirection = CGVectorMake(gravityDirectionX,  0)
    animator.addBehavior(gravityBehavior)
    
    /*
     A collision behavior confers, to a specified array of dynamic items, the ability of those items to engage in collisions with each other and with the behavior’s specified boundaries.
     For more details: https://developer.apple.com/reference/uikit/uicollisionbehavior
    */
    let collisionBehavior = UICollisionBehavior(items: [sideMenuContainerView])
    collisionBehavior.addBoundaryWithIdentifier("menuBoundary", fromPoint: CGPointMake(boundaryPointX, boundaryPointY), toPoint: CGPointMake(boundaryPointX, height))
    animator.addBehavior(collisionBehavior)
    
    /*
     A push behavior applies a continuous or instantaneous force to one or more dynamic items, causing those items to change position accordingly.
     For more details: https://developer.apple.com/reference/uikit/uipushbehavior
     */
    let pushBehavior = UIPushBehavior(items: [sideMenuContainerView], mode: UIPushBehaviorMode.Instantaneous)
    pushBehavior.magnitude = pushMagnitude
    animator.addBehavior(pushBehavior)
    
    /*
     A dynamic item behavior represents a base dynamic animation configuration for one or more dynamic items. Each of its properties overrides a corresponding default value.
     For more details: https://developer.apple.com/reference/uikit/uidynamicitembehavior
     */
    let menuViewBehavior = UIDynamicItemBehavior(items: [sideMenuContainerView])
    menuViewBehavior.elasticity = 0.15
    animator.addBehavior(menuViewBehavior)
  }
  
  public func toggleMenu() {
    // Revert boucingEnabled default value, because it might be changed by gesture handlers
    cacheIsBoucingEnabled = isMenuOpen ? false : boucingEnabled
    toggleMenu |> (!isMenuOpen, nil)
    if !isMenuOpen { updateSideMenuApperanceIfNeeded() }
  }
  
  public func hideSideMenu(completion: Completion? = nil) {
    // disable dynamic animator when hiding sidemenu
    cacheIsBoucingEnabled = false
    // Just only hide sidemenu if it has really shown
    if isMenuOpen { toggleMenu |> (false, completion) }
  }
  
  public func showSideMenu() {
    // Revert boucingEnabled default value, because it might be changed by gesture handlers
    cacheIsBoucingEnabled = boucingEnabled
    // Just only show sidemenu if it has really hidden
    if !isMenuOpen { toggleMenu |> (true, nil) }
  }
  
  public func refreshMenu(items: [String]) {
    // Refresh side menu with a new list items
    self.items = items
    menuViewController.sideMenuView.items = items
    menuViewController.sideMenuView.refresh()
  }
  
  public func updateFrame() {
    // Get adjusted frame dimensions that is dependent on ios version and device oriented
    let (width, height) = adjustFrameDimensions |> (CGRectGetWidth(sourceView.frame), CGRectGetHeight(sourceView.frame))
    // Re-assign container view frame based on menu location after getting adjusted frame dimensions
    sideMenuContainerView.frame = CGRectMake(position == .Left ? isMenuOpen ? 0: -menuWidth : isMenuOpen ? width - menuWidth : width+1
      , 0, width, height)
  }
  
  private func refreshSideMenu() {
    // Refresh side menu by updating its frame
    updateFrame()
    // Handle navigation bar translucent if needed
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
    // Handle if dynamic animator is in processing
    if !dynamicAnimatorEnded {
      dispatch_group_notify(dispatch_group, dispatch_get_main_queue(), { [weak self] in
        self?.handleDidSelectItemAtIndex(index)
      })
    } else {
      handleDidSelectItemAtIndex(index)
    }
  }
  
  private func handleDidSelectItemAtIndex(index: Int) {
    // Hide side menu if needed
    if hideWhenDidSelectOnCell {
      // Hide Sidemenu and perform a closure then
      hideSideMenu({ [unowned self] in
        // Calling delegate method after hiding sidemenu
        self.delegate?.didSelectItemAtIndex(index)
        })
    } else {
      // Send back did select item at index action by delegate
      delegate?.didSelectItemAtIndex(index)
    }
  }
}

extension LNSideMenu: UIDynamicAnimatorDelegate {
  public func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
    // Flag for dynamic animator did end animation
    dynamicAnimatorEnded = true
    // Release current dynamicAnimator task in dispatch group
    dispatch_group_leave(dispatch_group)
    // Calling delegate after dynamic animator did pause, 
    // in other word, the toogle sidemenu animation has already completed
    isMenuOpen ? delegate?.sideMenuDidOpen?() : delegate?.sideMenuDidClose?()
  }
  
  public func dynamicAnimatorWillResume(animator: UIDynamicAnimator) {
    // Enter dynamicAnimator task to main group
    dispatch_group_enter(dispatch_group)
  }
}
