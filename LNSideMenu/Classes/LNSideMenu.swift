//
//  LNSideMenu.swift
//  LNSideMenuEffect
//
//  Created by Luan Nguyen on 6/22/16.
//  Copyright © 2016 Luan Nguyen. All rights reserved.
//

import UIKit

public final class LNSideMenu: NSObject {
  
  public typealias Completion = () -> ()
  
  // FIXME: Should review it
  fileprivate let kDBXPoint: CGFloat = 10
  fileprivate let kGestureXPoint: CGFloat = 25
  fileprivate let kPushMagnitude: CGFloat = 15
  fileprivate let kGravityDirection: CGFloat = 3.5
  fileprivate let shortDuration: TimeInterval = 0.25
  fileprivate let maxXPan: CGFloat = 30

  // MARK: Properties
  // This property should be private for this release
  fileprivate var menuWidth: CGFloat = UIScreen.main.bounds.width {
    didSet {
      // Update sidemenu frame and something else, whenever menuWidth property gets a new value
      needUpdateAppearance = true
      updateSideMenuApperanceIfNeeded()
      updateFrame()
    }
  }
  
  /*
   If the content view's navigation bar is hidden or translucent, you should assign a `true` value to this property. 
   Otherwise, `false` value is that to moving down the default menu under navigation bar.
   */
  public var isNavbarHiddenOrTransparent = false {
    didSet {
      // Refresh side menu whenever this property is set a new value
      refreshSideMenu()
    }
  }
  /*
   For the custom menu, using this property to moving up/down to top (true) or under navigation bar(false).
   This property won't work for the default menu. 
   Check ``isNavbarHiddenOrTransparent`` out if you're planning to use the default menu.
   */
  public var underNavigationBar: Bool = false
  
  public weak var delegate: LNSideMenuDelegate?
  public var allowLeftSwipe = true
  public var allowRightSwipe = true
  public var allowPanGesture = true
  public var animationDuration = 0.5
  public var hideWhenDidSelectOnCell = true
  public var items = [String]()
  public var blurColor = UIColor.gray.withAlphaComponent(0.5)
  // uidynamic behavior, set false to disable it
  public var enableDynamic: Bool = false {
    didSet {
      cacheEnableDynamic = enableDynamic
    }
  }

  public var tapOutsideToDismiss = true
  public var disabled: Bool = false
  public var enableAnimation: Bool = true
  public var customMenu: UIViewController?
  public var isCustomMenu: Bool {
    return customMenu != nil
  }
  
  // MARK: Private properties
  fileprivate(set) public var isMenuOpen: Bool = false
  fileprivate(set) public var position: Position = .left
  fileprivate let sideMenuContainerView = UIView()
  fileprivate(set) public var menuViewController: LNPanelViewController?
  fileprivate var sourceView: UIView!
  fileprivate var needUpdateAppearance = false
  fileprivate var panGesture: UIPanGestureRecognizer?
  fileprivate var animator: UIDynamicAnimator!
  fileprivate var isGesture: Bool = false
  fileprivate var cacheEnableDynamic: Bool = true
  fileprivate var dynamicAnimatorEnded: Bool = true
  fileprivate let dispatch_group: DispatchGroup = DispatchGroup()
  fileprivate var animationCompleted: Bool = true
  
  fileprivate var ypos: CGFloat {
    if !isCustomMenu { return 0 }
    return underNavigationBar ? kNavBarHeight : 0
  }
  fileprivate lazy var blurView: UIView = {
    return self.initialBlurView()
  }()
  
  // MARK: Initialize
  
  fileprivate init(sourceView source: UIView, position: Position, isBlur: Bool = false) {
    super.init()
    sourceView = source
    self.position = position
    
    /// Adding blur if needed
    if isBlur {
      source.addSubview(blurView)
    }
    
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
    
    setupMenuView()
  }
  
  // Initial swipe gesture with specific direction
  fileprivate func initialSwipeGesture(_ direction: UISwipeGestureRecognizer.Direction) -> UISwipeGestureRecognizer {
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
  
  fileprivate func addGesture(_ pos: Position, handler: (UISwipeGestureRecognizer, UISwipeGestureRecognizer)->()) {
    // Register swipeGestures with its direction based on the inputting menu position
    let leftSwipeGesture = pos == .left ? initialSwipeGesture(.right) : initialSwipeGesture(.left)
    let rightSwipeGesture = pos == .left ? initialSwipeGesture(.left) : initialSwipeGesture(.right)
    handler(leftSwipeGesture, rightSwipeGesture)
    /// Tapping outside of sidemenu
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGesture(gesture:)))
    tapGesture.numberOfTapsRequired = 1
    tapGesture.numberOfTouchesRequired = 1
    tapGesture.delegate = self
    sideMenuContainerView.addGestureRecognizer(tapGesture)
  }
  
  // Initialize sidemenu by using default menu
  public convenience init(sourceView source: UIView, menuPosition: Position, items: [String], highlightItemAtIndex: Int = Int.max) {
    self.init(sourceView: source, position: menuPosition)
    self.items = items
    // Initial panel viewcontroller that is considered as a side menu viewcontroller
    self.menuViewController = LNPanelViewController(items: items, menuPosition: menuPosition, highlightCellAtIndex: highlightItemAtIndex)
    self.menuViewController?.delegate = self
    sideMenuContainerView.addSubview |> self.menuViewController!.view
  }
  
  // Initialize side menu without using default menu, using your own custom sidemenu instead
  public convenience init(navigation nav: UINavigationController, menuPosition: Position, customSideMenu: UIViewController, size: LNSize = .twothird) {
    self.init(sourceView: nav.view, position: menuPosition, isBlur: true)
    // Keep references
    customMenu = customSideMenu
    
    // Config custom menu view
    customMenu?.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    customMenu?.view.frame = sideMenuContainerView.bounds
    customMenu?.view.frame.width = size.width
    if menuPosition == .right { customMenu?.view.x = sourceView.width - size.width }
    
    // Adding blur view under custom side menu
    blurView.alpha = 0
    
    // Adding subview
    sideMenuContainerView.addSubview |> customMenu!.view
  }
  
  fileprivate func initialBlurView() -> UIView {
    // Add blur view for custom sidemenu
    let blurView = UIView(frame: sideMenuContainerView.bounds)
    blurView.backgroundColor = blurColor
    blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    return blurView
  }
  
  // MARK: Setup and configure
  
  fileprivate func setupMenuView() {
    
    // Configure side menu container frame
    updateFrame()
    
    // Setup container views
    sideMenuContainerView.backgroundColor = .clear
    sourceView.addSubview |> sideMenuContainerView
  }
  
  fileprivate func updateSideMenuApperanceIfNeeded() {
    // Update sidemune appearance if needed, it means if there has a change of any related view frame that might effects
    // the sidemenu frame, we must update the sidemenu containerview frame and layer.
    if needUpdateAppearance {
      sideMenuContainerView.width = menuWidth
      sideMenuContainerView.layer.shadowPath = UIBezierPath(rect: sideMenuContainerView.bounds).cgPath
      needUpdateAppearance = false
    }
  }
  
  // MARK: Gesture handlers
  
  @objc internal func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
    guard !disabled else { return }
    let leftToRight = gesture.velocity(in: gesture.view).x > 0
    switch gesture.state {
    case .began:
      // Always kill scrolling whenever pan gesture is being started
      if !isCustomMenu {
        menuViewController?.sideMenuView.killScrolling()
      }
      break
    case .changed:
      
      let translation = gesture.translation(in: sourceView).x
      let xpoint = sideMenuContainerView.center.x + translation + (position == .left ? 1: -1) * menuWidth / 2
      
      if position == .left {
        if xpoint <= 0 || xpoint > sideMenuContainerView.frame.width {
          return
        }
      } else {
        if xpoint <= sourceView.width - menuWidth || xpoint >= sourceView.width {
          return
        }
      }
      sideMenuContainerView.center.x = sideMenuContainerView.center.x + translation
      animateBlurview(byOffset: (true, sideMenuContainerView.center.x))
      gesture.setTranslation(.zero, in: sourceView)

    default:
      let velX = gesture.velocity(in: gesture.view).x
      if velX == 0 {
        if (position == .left && sideMenuContainerView.x == -menuWidth)
          || (position == .right && sideMenuContainerView.x == menuWidth) {
          return
        }
      }
      let shouldClose = position == .left ? !leftToRight && sideMenuContainerView.frame.maxX < menuWidth-maxXPan : leftToRight && sideMenuContainerView.frame.minX > maxXPan
      cacheEnableDynamic = false
      panToogleMenu(!shouldClose)
    }
  }
  
  @objc internal func handleGesture(_ gesture: UISwipeGestureRecognizer) {
    // Toggle side menu by swipe gesture direction
    cacheEnableDynamic = false
    toggleMenu((position == .right && gesture.direction == .left) || (position == .left && gesture.direction == .right))
  }

  @objc internal func tapGesture(gesture: UIGestureRecognizer) {
    guard tapOutsideToDismiss else { return }
    if let custom = customMenu?.view {
      if !custom.frame.contains(gesture.location(in: sideMenuContainerView)) {
        toggleMenu()
      }
    } else {
      if let touch = sideMenuContainerView.subviews.first?.subviews.first as? LNSideMenuView {
        if let scrollView = touch.subviews.filter({ $0 is UIScrollView }).first {
          let bounds = scrollView.convert(scrollView.bounds, to: sideMenuContainerView)
          if bounds.contains(gesture.location(in: sideMenuContainerView)) {
            return
          }
        }
      }
      toggleMenu()
    }
  }
  
  // MARK: Animations
  
  fileprivate func animateSideMenu(_ isShow: Bool, animation: Bool = true, completion: Completion? = nil) {
    // Do nothing if the menu was disabled
    if disabled || !dynamicAnimatorEnded { return }
    // Do nothing if the expected
    if isShow && delegate?.sideMenuShouldOpenSideMenu?() == false {
      return
    }
    // Should update if needed
    updateSideMenuApperanceIfNeeded()
    isMenuOpen = isShow
    let (width, height) = adjustFrameDimensions |> (sourceView.frame.width, sourceView.frame.height)
    // Check if it's allowed to performing dynamic animation
    if cacheEnableDynamic {
      // Change ended anymator flag to false before starting dynamic animator
      dynamicAnimatorEnded = false
      // Delegate sidemenu will open/close
      isShow ? delegate?.sideMenuWillOpen?() : delegate?.sideMenuWillClose?()
      // If bouncing enabled is true, performing dynamic behavior instead of standard animation
      dynamicBehavior(isShow, width: width, height: height)
      // Starting show/hide blur view animation
      animateBlurview(isShow: isShow)
      return
    }
    animationCompleted = false
    // Preparing for animating menu's contents
    var duration = animationDuration
    if isShow && animation && !isCustomMenu {
      menuViewController?.prepareForAnimation()
      duration = shortDuration
    }
    // Calculating destination sidemenu frame based on the menu position and isShow param
    let destFrame = position == .left ? CGRect(x: isShow ? 0: -menuWidth, y: ypos, width: menuWidth, height: height) :
      CGRect(x: isShow ? width-menuWidth : width, y: ypos, width: menuWidth, height: height)
    // Performing a standard animation
    let closure = {
      self.isMenuOpen ? self.delegate?.sideMenuDidOpen?() : self.delegate?.sideMenuDidClose?()
      // Begins animating menu's contents
      if let completion = completion { completion() }
      self.animationCompleted = true
    }
    UIView.animate(withDuration: duration, animations: {
      self.sideMenuContainerView.frame = destFrame
      }, completion: { _ in
        if !(isShow && animation && !self.isCustomMenu) { closure() }
    })
    if isShow && animation && !isCustomMenu {
      // Performing menu's contents fade animation
      menuViewController?.animateContents() {
        closure()
      }
    }
    // Starting show/hide blur view animation
    animateBlurview(isShow: isShow)
    isShow ? delegate?.sideMenuWillOpen?() : delegate?.sideMenuWillClose?()
  }
  
  fileprivate func animateBlurview(isShow: Bool = false, byOffset offset: (Bool, CGFloat)? = nil) {
    if !isCustomMenu { return }
    var alpha: CGFloat = isShow ? 1: 0
    // Calculating alpha val by offset if required
    if let offset = offset, offset.0 {
      alpha = offset.1 / (sideMenuContainerView.width/2)
      alpha = 0...1 ~= alpha ? alpha : alpha < 0 ? 0 : 1
    }
    // Animating show/hide blur view by alpha
    let duration = isShow ? animationDuration : 0.05
    UIView.animate(withDuration: duration) {
      self.blurView.alpha = alpha
    }
  }
  
  fileprivate func dynamicBehavior(_ shouldOpen: Bool, width: CGFloat, height: CGFloat) {
    
    // Once this function is called then we must clean up UIDynamicAnimator object
    animator.removeAllBehaviors()
    
    var gravityDirectionX: CGFloat
    var pushMagnitude: CGFloat
    var boundaryPointX: CGFloat
    var boundaryPointY: CGFloat
    
    if (position == .left) {
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
    gravityBehavior.gravityDirection = CGVector(dx: gravityDirectionX, dy: 0)
    animator.addBehavior(gravityBehavior)
    
    /*
     A collision behavior confers, to a specified array of dynamic items, the ability of those items to engage in collisions with each other and with the behavior’s specified boundaries.
     For more details: https://developer.apple.com/reference/uikit/uicollisionbehavior
    */
    let collisionBehavior = UICollisionBehavior(items: [sideMenuContainerView])
    collisionBehavior.addBoundary(withIdentifier: "menuBoundary" as NSCopying, from: CGPoint(x: boundaryPointX, y: boundaryPointY), to: CGPoint(x: boundaryPointX, y: height))
    animator.addBehavior(collisionBehavior)
    
    /*
     A push behavior applies a continuous or instantaneous force to one or more dynamic items, causing those items to change position accordingly.
     For more details: https://developer.apple.com/reference/uikit/uipushbehavior
     */
    let pushBehavior = UIPushBehavior(items: [sideMenuContainerView], mode: UIPushBehavior.Mode.instantaneous)
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
  
  // MARK: Toggle Menu
  
  fileprivate func panToogleMenu(_ show: Bool) {
    var centerx = sourceView.center.x
    if !show {
      centerx = position == .left ? -sourceView.width/2 : sourceView.width + sourceView.width/2
    }
    let stateChanged = show != isMenuOpen
    if stateChanged {
      show ? delegate?.sideMenuWillOpen?() : delegate?.sideMenuWillClose?()
      isMenuOpen = show
    }
    UIView.animate(withDuration: animationDuration, animations: {
      self.sideMenuContainerView.center.x = centerx
    }) { _ in
      self.animationCompleted = true
      if stateChanged {
        show ? self.delegate?.sideMenuDidOpen?() : self.delegate?.sideMenuDidClose?()
      }
    }
    // Starting show/hide blur view animation
    animateBlurview(isShow: show)
  }
  
  fileprivate func toggleMenu(_ isShow: Bool, completion: Completion? = nil) {
    // Waiting until all animations are done
    if animationCompleted {
      let animation = isShow && self.isMenuOpen ? false : self.enableAnimation
      self.animateSideMenu(isShow, animation: animation, completion: completion)
    }
  }
  
  public func toggleMenu(completion: Completion? = nil) {
    // Revert boucingEnabled default value, because it might be changed by gesture handlers
    cacheEnableDynamic = isMenuOpen ? false : enableDynamic
    toggleMenu(!isMenuOpen, completion: completion)
    if !isMenuOpen { updateSideMenuApperanceIfNeeded() }
  }
  
  public func hideSideMenu(_ completion: Completion? = nil) {
    // disable dynamic animator when hiding sidemenu
    cacheEnableDynamic = false
    // Just only hide sidemenu if it was really shown
    if isMenuOpen { toggleMenu(false, completion: completion) }
  }
  
  public func showSideMenu(completion: Completion? = nil) {
    // Revert boucingEnabled default value, because it might be changed by gesture handlers
    cacheEnableDynamic = enableDynamic
    // Just only show sidemenu if it was really hidden
    if !isMenuOpen { toggleMenu(true, completion: completion) }
  }
  
  // MARK: Frame and refresh content
  
  public func refreshMenu(_ items: [String]) {
    // Refresh side menu with a new list items
    self.items = items
    if !isCustomMenu {
      menuViewController?.sideMenuView.items = items
      menuViewController?.sideMenuView.refresh()
    }
  }
  
  internal func updateFrame() {
    // Get adjusted frame dimensions that is dependent on ios version and device oriented
    let (width, height) = adjustFrameDimensions |> (sourceView.frame.width, sourceView.frame.height)
    // Re-assign container view frame based on menu position after getting adjusted frame dimensions
    sideMenuContainerView.frame = CGRect(x: position == .left ? isMenuOpen ? 0: -menuWidth : isMenuOpen ? width - menuWidth : width+1
      , y: ypos, width: width, height: height)
    // Update blur view y position
    if isCustomMenu {
      blurView.frame = CGRect(x: 0, y: ypos - 20, width: sideMenuContainerView.width, height: sideMenuContainerView.height + abs(ypos - 20))
    }
  }
  
  // Implementing set content viewcontroller effection
  fileprivate func transitionContentVC(completion: Completion) {
    // TODO:
  }
  
  fileprivate func refreshSideMenu() {
    // Refresh side menu by updating its frame
    updateFrame()
    // Handle navigation bar translucent if needed
    if !isCustomMenu {
      menuViewController?.isTranslucent = isNavbarHiddenOrTransparent
    }
  }
  
  fileprivate func adjustFrameDimensions( _ width: CGFloat, height: CGFloat ) -> (CGFloat,CGFloat) {
    return (width, height-ypos)
  }
}

// MARK: LNSMDelegate

extension LNSideMenu: LNSMDelegate {
  func didSelectItemAtIndex(SideMenu: LNSideMenuView, index: Int) {
    // Handle if dynamic animator is in processing
    if !dynamicAnimatorEnded {
      dispatch_group.notify(queue: DispatchQueue.main, execute: { [weak self] in
        self?.handleDidSelectItemAtIndex(index)
      })
    } else {
      handleDidSelectItemAtIndex(index)
    }
  }
  
  fileprivate func handleDidSelectItemAtIndex(_ index: Int) {
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

// MARK: Dynamic animator delegate

extension LNSideMenu: UIDynamicAnimatorDelegate {
  public func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
    // Flag for dynamic animator did end animation
    dynamicAnimatorEnded = true
    // Release current dynamicAnimator task in dispatch group
    dispatch_group.leave()
    // Calling delegate after dynamic animator did pause, 
    // in other word, the toogle sidemenu animation has already completed
    isMenuOpen ? delegate?.sideMenuDidOpen?() : delegate?.sideMenuDidClose?()
  }
  
  public func dynamicAnimatorWillResume(_ animator: UIDynamicAnimator) {
    // Enter dynamicAnimator task to main group
    dispatch_group.enter()
  }
}

extension LNSideMenu: UIGestureRecognizerDelegate {

  public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    // Disable gesture if dynamic animator has not ended animation yet
    if !dynamicAnimatorEnded {
      return false
    }
    // Disable gesture until the toggle menu animation is completed
    if !animationCompleted {
      return false
    }
    // Such as pan gesture, kill menu scrolling whenever user swipes on view
    if !isCustomMenu {
      menuViewController?.sideMenuView.killScrolling()
    }
    if let shouldOpen = delegate?.sideMenuShouldOpenSideMenu?() , !shouldOpen {
      return false
    }

    if let gestureRecognizer = gestureRecognizer as? UISwipeGestureRecognizer {
      if !allowLeftSwipe && gestureRecognizer.direction == .left {
        return false
      }

      if !allowRightSwipe && gestureRecognizer.direction == .right {
        return false
      }
    } else if gestureRecognizer == panGesture {
      if !allowPanGesture {
        return false
      }

      let touchPosition = gestureRecognizer.location(ofTouch: 0, in: sourceView)
      if position == .left {
        if isMenuOpen && touchPosition.x < menuWidth {
          return true
        }
        if touchPosition.x < kGestureXPoint {
          return true
        }
      } else {
        if isMenuOpen && touchPosition.x > sourceView.frame.width - menuWidth {
          return true
        }
        if touchPosition.x > sourceView.frame.width - kGestureXPoint {
          return true
        }
      }
      return false
    }
    return true
  }

  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }

  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    if gestureRecognizer is UITapGestureRecognizer, tapOutsideToDismiss {
      if let menu = customMenu?.view, let touchView = touch.view, touchView.isDescendant(of: menu) {
        return false
      }
    }
    return true
  }
}
