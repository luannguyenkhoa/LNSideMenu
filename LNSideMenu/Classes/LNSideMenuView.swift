//
//  SideMenuView.swift
//  SwiftExample
//
//  Created by Luan Nguyen on 6/22/16.
//  Copyright (c) 2015 luannguyen. All rights reserved.
//

import UIKit
import CoreGraphics
import QuartzCore

internal final class LNSideMenuView: UIView, UIScrollViewDelegate {
  
  // MARK: Constants
  fileprivate let kNumberDefaultItemHeight: CGFloat = 60
  fileprivate let kNumberDefaultSpace: CGFloat = 30
  fileprivate let kNumberDefaultDistance: CGFloat = 40
  fileprivate let kNumberDurationAnimation: TimeInterval = 0.25
  fileprivate let kNumberDefaultItemsHoziConstant: Int = 2
  fileprivate let kNumberAriProg: Int = 10
  fileprivate let kNumberVelocityConstant: CGFloat = 60
  
  // MARK: Variables
  var indexOfDefaultCellHighlight: Int = Int.max
  
  fileprivate var totalCells: Int = 10
  fileprivate var totalCellOnScreen: Int = 10
  fileprivate var velocity: CGFloat = 0
  fileprivate var pos: CGFloat = 0
  fileprivate var currentIndex: Int = 0
  fileprivate var lastContentOffset: CGFloat = 0
  fileprivate var index: Int = 0
  fileprivate var lastIndex: Int = 0
  fileprivate var highlightItemWhenDidTouch: Bool = true
  fileprivate var isDidShow: Bool = false
  fileprivate var originalXRight: CGFloat = 0
  fileprivate var originalXLeft: CGFloat = 0
  fileprivate var prepared: Bool = false
  fileprivate var didComplete: Bool = true
  fileprivate var delay: TimeInterval = 0
  
  fileprivate var views: [UIView]! = [UIView]()
  var items = [""]
  
  // MARK: Colors
  var bgColor = LNColor.bgView.color
  var itemBgColor = LNColor.bgItem.color
  var highlightColor = LNColor.highlight.color
  var titleColor = LNColor.title.color
  
  // MARK: Components
  fileprivate var menusScrollView: UIScrollView! = UIScrollView()
  fileprivate var panRecognizer: UIPanGestureRecognizer?
  fileprivate var sourceView: UIView?
  fileprivate var currentItem: UIView?
  
  // MARK: Position of SideMenu
  var currentPosition: Position = .left {
    didSet {
      switch currentPosition {
      case .left:
        self.setupMenusAtLeft()
      case .right:
        self.setupMenusAtRight()
      }
    }
  }
  
  // MARK: Protocols
  internal weak var delegate: LNSMDelegate?
  
  // MARK: LifeCycle
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  required  init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: Setup SideMenu
  
  /**
   Setup SideMenu components
   
   :param: sourceView the parent view
   */
  func setupMenu(_ sourceView: UIView, position: Position) {
    
    self.sourceView = sourceView
    // Initialize view frame
    let xpos = position == .left ? 0 : sourceView.width/2
    self.frame = CGRect(x: xpos, y: 0, width: sourceView.width/2, height: sourceView.height)
    
    // Initialize main scrollview and setting colors
    self.backgroundColor = .clear
    
    // Initial main scrollView
    self.initializeMenuScrollView |> (position == .right)
    
    // Set menu position on superview
    currentPosition = position
    
    // Drawing a background view
    self.draw(_:) |> self.frame
    currentItem = menusScrollView.viewWithTag |> indexOfDefaultCellHighlight
    
    // Add self to parent view
    sourceView.addSubview |> self
    sourceView.bringSubview(toFront:) |> self
    
  }
  
  func refreshMenuWithFrame(_ frame: CGRect, isChanged: Bool) {
    // Clear drawn shape in self
    clearDrawRect(self.frame)
    // Update height
    self.height = frame.height
    // Re-draw shape in self
    draw(self.frame)
    // Update x position of scrollview
    let distanceToTop = isChanged ? navigationBarHeight : kNumberDefaultSpace
    self.menusScrollView.y = distanceToTop
  }
  
  func refresh() {
    // Remove all current items
    menusScrollView.subviews.forEach{ $0.removeFromSuperview() }
    // Reinit menus view with the new list of items
    initialItems(currentPosition == .right)
  }
  
  // Forcing stop scrolling scrollview
  func killScrolling() {
    let offset = menusScrollView.contentOffset
    menusScrollView.setContentOffset |> (offset, false)
  }
  
  /**
   Initialize Menu scrollview, which contain all items
   */
  fileprivate func initializeMenuScrollView(_ isRight: Bool) {
    // Config menu scrollview
    menusScrollView.delegate = self
    menusScrollView.isScrollEnabled = true
    menusScrollView.backgroundColor = UIColor.clear
    menusScrollView.showsVerticalScrollIndicator = false
    menusScrollView.showsHorizontalScrollIndicator = false
    
    // Calculate total cells be able displayed on screen
    
    let space: CGFloat = self.height - kNumberDefaultSpace
    var frame = self.frame
    frame.width = isRight ? frame.width : frame.width - kNumberDefaultDistance
    totalCellOnScreen = items.count
    
    var height: CGFloat = CGFloat(Int(kNumberDefaultItemHeight) * totalCellOnScreen)
    while height > space {
      totalCellOnScreen -= 1
      height = CGFloat(kNumberDefaultItemHeight) * CGFloat(totalCellOnScreen)
    }
    frame.height = height + 10
    
    totalCells = items.count
    // The number of items on screen is always an odd, because it helps to calculate frames of items more easier and cooler
    if totalCellOnScreen % 2 == 0 && totalCells > totalCellOnScreen {
      totalCellOnScreen -= 1
    }
    // CurrentIndex is presented for index of item at center of screen
    currentIndex = Int(totalCellOnScreen/2)
    index = currentIndex
    // Calculate frame of scrollview
    frame.y = kNumberDefaultSpace
    frame.x = isRight ? kNumberDefaultDistance : 0
    menusScrollView.frame = frame
  }
  
  /**
   Setup Menu at the screen right
   */
  fileprivate func setupMenusAtRight() {
    initialItems |> true
  }
  
  /**
   Setup Menu at the screen left
   */
  fileprivate func setupMenusAtLeft() {
    initialItems |> false
  }
  /**
   A common method that will helps to initialize side menu
   
   - parameter right: position of side menu
   */
  fileprivate func initialItems(_ right: Bool) {
    if items.count == 0 {
      return
    }
    if totalCells < 0 {
      return
    }
    // Clear all subviews before adding new ones
    views.removeAll()
    
    for index in 0 ..< totalCells {
      // Calculate item frame by its index
      let dest = abs(index-currentIndex)
      let sum = (0..<dest).reduce(0, { $0 + $1*kNumberAriProg })
      let originX = (right ? 1 : -1) * CGFloat(sum + kNumberDefaultItemsHoziConstant*dest)
      let itemFrame = CGRect(x: originX, y: CGFloat(index*Int(kNumberDefaultItemHeight)), width: menusScrollView.width, height: kNumberDefaultItemHeight)
      
      // Initial item by index
      let itemView = LNItemView()
      itemView.setupView |> (itemFrame, items[index], index==indexOfDefaultCellHighlight, right, titleColor, highlightColor, itemBgColor)
      itemView.tag = index
      // add single tap gesture for each item of menu
      let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapContentView(_:)))
      tapGesture.numberOfTapsRequired = 1
      itemView.addGestureRecognizer |> tapGesture
      // Add item to scrollview
      self.menusScrollView.addSubview |> itemView
      // Cache list of items
      views.append(itemView)
    }
    menusScrollView.contentSize = CGSize(width: menusScrollView.width, height: CGFloat(totalCells*Int(kNumberDefaultItemHeight)))
    self.addSubview |> self.menusScrollView
  }
  
  // MARK: Action handler functions
  
  /**
   Change items frame when the user scrolling
   */
  fileprivate func animationToIndex(_ index: Int, animated: Bool) {
    
    var animate = animated
    var speed: CGFloat = 0
    if (velocity > kNumberVelocityConstant){
      animate = false // Disable animation change item frame if the user scrolling too fast
    }
    if (animate){
      speed = 0.005
    }
    var currentViewIndex = 0
    for view in views where view is LNItemView {
      if currentViewIndex == index {
        self.updateItemViewWidth |> (view as! LNItemView, speed)
      } else {
        self.updateItemViewFor |> (view as! LNItemView, currentViewIndex, index, speed)
      }
      currentViewIndex += 1
    }
  }
  
  /**
   Get origin x postion of current item in the next frame
   */
  fileprivate func getXpos(_ dest: Int) -> CGFloat {
    let cdest = dest < 0 ? 0 : dest
    let sum = (0..<cdest).reduce(0, {$0 + $1*kNumberAriProg})
    let xpos = currentPosition == .right ? CGFloat(sum + kNumberDefaultItemsHoziConstant*cdest) : -CGFloat(sum + kNumberDefaultItemsHoziConstant*cdest)
    return xpos
  }
  
  /**
   Update frame of current item by offset value
   */
  fileprivate func updateXpos(_ frame: CGRect, offset: CGFloat, dist: CGFloat, plus: Bool) -> CGRect {
    let num: CGFloat = plus ? 1 : -1
    var frame = frame
    frame.x += (currentPosition == .right ? num: -num) * (offset * dist / kNumberDefaultItemHeight)
    return frame
  }
  
  /**
   Update items frame by scrollview content offset
   */
  fileprivate func changeItemsFrameByOffset(_ scrollUp: Bool, offset: CGFloat, currentIndex: Int) {
    var currentViewIndex = 0
    for view in views {
      var dest = abs(currentViewIndex-currentIndex)
      if currentViewIndex <= currentIndex { dest += scrollUp ? 1 : -1 } else { dest -= scrollUp ? 1 : -1 }
      let xpos = self.getXpos(dest)
      let frame = view.frame
      let dist = abs(view.x - xpos)
      let plus = scrollUp ? currentViewIndex <= currentIndex : !(currentViewIndex <= currentIndex)
      view.frame = self.updateXpos(frame, offset: offset, dist: dist, plus: plus)
      currentViewIndex += 1
    }
  }
  
  /**
   Update item frame if it's current item
   */
  fileprivate func updateItemViewWidth(_ currentView: LNItemView, speed: CGFloat) {
    animateUpdateView { return 0 } |> (currentView, speed)
  }
  
  /**
   Update other items frame
   */
  fileprivate func updateItemViewFor(_ itemView: LNItemView, index: Int, current: Int, speed: CGFloat) {
    animateUpdateView { [unowned self] _ in
      let dest = abs(index-current)
      let sum = (0..<dest).reduce(0, {$0 + $1*self.kNumberAriProg})
      let originX = self.currentPosition == .right ? CGFloat(sum + 2*dest) : -CGFloat(sum + self.kNumberDefaultItemsHoziConstant*dest)
      return originX
    } |> (itemView, speed)
  }
  
  fileprivate func animateUpdateView<A: UIView>(_ calculateX: () -> CGFloat) -> (A, CGFloat) -> () {
    let xpos = calculateX()
    return { view, speed in
      UIView.animate(withDuration: TimeInterval(speed), delay: 0, options: .curveLinear, animations: { () -> Void in
        view.x = xpos
      })
      UIView.commitAnimations()
    }
  }
  
  internal func prepareForAnimation() {
    // Moving items to destint xpos
    for item in views {
      animateItemByUpdatingXpos(item: item, isIn: false)
    }
    prepared = true
  }
  
  internal func animateContents(completion: @escaping Completion) {
    didComplete = false
    // Check if the animation was prepared before then performing animation
    if prepared {
      // Animate
      var startIdx: Int = Int(floor(menusScrollView.contentOffset.y / (views.first?.height ?? 1)))
      if 0..<views.count ~= startIdx {
        delay = 0
        startIdx = startIdx == 0 ? 0 : startIdx - 1
        animation |> (startIdx, views.count, startIdx == 0, completion)
        if startIdx > 0 { animation |> (0, startIdx, true, completion) }
      }
      prepared = false
    } else {
       completion()
    }
  }
  
  fileprivate func animation(startIdx: Int, endIdx: Int, end: Bool, completion: Completion? = nil) {
    let sum = views.count
    for idx in startIdx..<endIdx where 0..<sum ~= idx {
      UIView.animate(withDuration: kNumberDurationAnimation, delay: delay, options: .curveEaseInOut, animations: {
        self.animateItemByUpdatingXpos(item: self.views[idx], isIn: true)
        }, completion: { _ in
          if idx == endIdx-1 && end {
            self.didComplete = true
            // Callback when the animations all are done
            if let completion = completion { completion() }
          }
      })
      // Increasing delay time by animation time after each animation performed that will playing animations by order
      delay += kNumberDurationAnimation/3
    }
  }
  
  fileprivate func animateItemByUpdatingXpos(item: UIView, isIn: Bool) {
    if currentPosition == .left {
      isIn ? inoutMath(+=, &item.x, item.width) : inoutMath(-=, &item.x, item.width)
    } else {
      let width = item.width + kDistanceItemToRight
      isIn ? inoutMath(-=, &item.x, width) : inoutMath(+=, &item.x, width)
    }
  }

  // MARK: SideMenuDelegate
  /**
   Did tap on item handler
   */
  func didTapContentView(_ sender: UIGestureRecognizer) {
    if !didComplete { return }
    let view = sender.view
    let index = view?.tag
    delegate?.didSelectItemAtIndex(SideMenu: self, index: index ?? 0)
    if highlightItemWhenDidTouch {
      if let label = currentItem?.viewWithTag(101) as? UILabel {
        label.textColor = titleColor
      }
      if let currentLabel = view?.viewWithTag(101) as? UILabel {
        currentLabel.textColor = highlightColor
      }
      currentItem = view
    }
  }
  
  // MARK: UIScrollViewDelegate
  /**
   Handle scrolling and change items frame on the view
   */
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    
    let yOffset = scrollView.contentOffset.y
    velocity = pos - yOffset
    pos = yOffset
    
    let div: CGFloat = scrollView.contentOffset.y / kNumberDefaultItemHeight
    if abs( scrollView.contentOffset.y - lastContentOffset) >= kNumberDefaultSpace {
      var optDiv: Int = 0
      if lastContentOffset > scrollView.contentOffset.y {
        optDiv = Int(div)
      } else {
        optDiv = Int(round(div))
      }
      index = currentIndex + optDiv
      lastContentOffset = CGFloat(Int(kNumberDefaultItemHeight) * optDiv)
    }
    
    let scrollUp: Bool = velocity <= 0
    if abs(velocity) > 40 {
      self.animationToIndex(index, animated: true)
    } else {
      self.changeItemsFrameByOffset(scrollUp, offset: abs(velocity), currentIndex: index)
    }
  }
  
  //MARK:  functions
  
  /**
   Enable highlight item when did touch on it
   */
  func enableHighlightItem() {
    highlightItemWhenDidTouch = true
  }
  
  // MARK: Drawing
  /*
   Using Core Graphic for drawing shapes by positions. CGContext is a powerful package for doing this feature.
   The CGContextRef opaque type represents a Quartz 2D drawing destination.
   
   For more details: https://developer.apple.com/library/mac/documentation/GraphicsImaging/Reference/CGContext/
   */
  
  fileprivate func clearDrawRect(_ rect: CGRect) {
    guard let context = UIGraphicsGetCurrentContext() else { return }
    context.clear(rect)
    context.closePath()
  }
  
  /**
   Draw a shape with a curve line and 3 straight lines on the owner view
   */
  override  func draw(_ rect: CGRect) {
    guard let context = UIGraphicsGetCurrentContext() else { return }
    let size = rect.size
    context.setStrokeColor(UIColor.clear.cgColor);
    context.setLineWidth(3)
    // Draw the polygon
    if currentPosition == .left {
      self.drawShapeForLeftView(currentContext: context, size: size)
    } else {
      self.drawShapeForRightView(currentContext: context, size: size)
    }
    
    // Fill it
    context.setFillColor(bgColor.cgColor)
    
    // Stroke it
    context.drawPath(using: .fillStroke)
    // End context
    UIGraphicsEndImageContext()
  }
  
  /**
   Draw a shape for left view, this func is called when the SideMenu on the screen left
   */
  fileprivate func drawShapeForLeftView(currentContext: CGContext, size: CGSize) {
    currentContext.move(to: CGPoint(x: 0, y: 0))
    currentContext.addLine(to: CGPoint(x: size.width/2.4, y: 0))
    currentContext.addQuadCurve(to: CGPoint(x: size.width/2.4, y: size.height), control: CGPoint(x: size.width + size.width/2, y: size.height/2))
    currentContext.addLine(to: CGPoint(x: 0, y: size.height)) // base
    currentContext.addLine(to: CGPoint(x: 0, y: 0)); // right border
  }
  
  /**
   Draw a shape for right view, this func is called when the SideMenu on the screen right
   */
  fileprivate func drawShapeForRightView(currentContext: CGContext, size: CGSize) {
    currentContext.move(to: CGPoint(x: size.width, y: 0))
    currentContext.addLine(to: CGPoint(x: size.width - size.width/2.4, y: 0))
    currentContext.addQuadCurve(to: CGPoint(x: size.width - size.width/2.4, y: size.height), control: CGPoint(x: -size.width/2, y: size.height/2))
    currentContext.addLine(to: CGPoint(x: size.width, y: size.height)) // base
    currentContext.addLine(to: CGPoint(x: size.width, y: 0)); // right border
  }
  
}
