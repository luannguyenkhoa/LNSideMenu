//
//  SideMenuView.swift
//  SwiftExample
//
//  Created by Luan Nguyen on 6/22/16.
//  Copyright (c) 2015 luannguyen. All rights reserved.
//

import UIKit
import CoreGraphics

internal class LNSideMenuView: UIView, UIScrollViewDelegate {
  
  // MARK: Constants
  private let kNumberDefaultItemHeight: CGFloat = 60
  private let kNumberDefaultSpace: CGFloat = 30
  private let kNumberDefaultDistance: CGFloat = 40
  private let kNumberDurationAnimation: CGFloat = 0.25
  private let kNumberDefaultItemsHoziConstant: Int = 2
  private let kNumberAriProg: Int = 10
  private let kNumberVelocityConstant: CGFloat = 60
  
  // MARK: Variables
  var indexOfCellHighlight: Int = Int.max
  
  private var totalCells: Int = 10
  private var totalCellOnScreen: Int = 10
  private var velocity: CGFloat = 0
  private var pos: CGFloat = 0
  private var currentIndex: Int = 0
  private var lastContentOffset: CGFloat = 0
  private var index: Int = 0
  private var lastIndex: Int = 0
  private var highlightItemWhenDidTouch: Bool = false
  private var isDidShow: Bool = false
  private var originalXRight: CGFloat = 0
  private var originalXLeft: CGFloat = 0
  
  private var views: NSMutableArray! = NSMutableArray()
  var items = [""]
  
  // MARK: Colors
  var bgColor = LNDefaultColor.BackgroundColor.color()
  var itemBackgroundColor = LNDefaultColor.ItemBackgroundColor.color()
  var highlightItemColor = LNDefaultColor.HighlightItem.color()
  var itemTitleColor = LNDefaultColor.ItemTitleColor.color()
  
  // MARK: Components
  private var menusScrollView: UIScrollView! = UIScrollView()
  private var panRecognizer: UIPanGestureRecognizer?
  private var sourceView: UIView?
  private var currentItem: UIView?
  
  // MARK: Position of SideMenu
  var currentPosition: Position = .Left {
    didSet {
      switch currentPosition {
      case .Left:
        self.setupMenusAtLeft()
      case .Right:
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
  func setupMenu(sourceView: UIView, position: Position) {
    
    self.sourceView = sourceView
    // Initialize view frame
    let xpos = position == .Left ? 0 : CGRectGetWidth(sourceView.frame)/2
    self.frame = CGRectMake(xpos, 0, CGRectGetWidth(sourceView.frame)/2, CGRectGetHeight(sourceView.frame))
    
    // Initialize main scrollview and setting colors
    self.backgroundColor = .clearColor()
    
    // Initial main scrollView
    self.initializeMenuScrollView |> (position == .Right)
    
    // Set menu position on superview
    currentPosition = position
    
    // Drawing a background view
    self.drawRect |> self.frame
    currentItem = menusScrollView.viewWithTag |> indexOfCellHighlight
    
    // Add self to parent view
    sourceView.addSubview |> self
    sourceView.bringSubviewToFront |> self
    
  }
  
  func refreshMenuWithFrame(frame: CGRect, isChanged: Bool) {
    // Clear drawn shape in self
    clearDrawRect(self.frame)
    // Update height
    self.frame.size.height = CGRectGetHeight(frame)
    // Re-draw shape in self
    drawRect(self.frame)
    // Update x position of scrollview
    let distanceToTop = isChanged ? navigationBarHeight : kNumberDefaultSpace
    self.menusScrollView.frame.origin.y = distanceToTop
  }
  
  func refresh() {
    // Remove all current items
    menusScrollView.subviews.forEach{ $0.removeFromSuperview() }
    // Reinit menus view with the new list of items
    initialItems |> currentPosition == .Right
  }
  
  // Forcing stop scrolling scrollview
  func killScrolling() {
    let offset = menusScrollView.contentOffset
    menusScrollView.setContentOffset |> (offset, false)
  }
  
  /**
   Initialize Menu scrollview, which contain all items
   */
  private func initializeMenuScrollView(isRight: Bool) {
    // Config menu scrollview
    menusScrollView.delegate = self
    menusScrollView.scrollEnabled = true
    menusScrollView.backgroundColor = UIColor.clearColor()
    menusScrollView.showsVerticalScrollIndicator = false
    menusScrollView.showsHorizontalScrollIndicator = false
    
    // Calculate total cells be able displayed on screen
    
    let space: CGFloat = self.frame.size.height - kNumberDefaultSpace
    var frame = self.frame
    frame.size.width = isRight ? frame.size.width : frame.size.width - kNumberDefaultDistance
    totalCellOnScreen = items.count
    
    var height: CGFloat = CGFloat(Int(kNumberDefaultItemHeight) * totalCellOnScreen)
    while height > space {
      totalCellOnScreen -= 1
      height = CGFloat(kNumberDefaultItemHeight) * CGFloat(totalCellOnScreen)
    }
    frame.size.height = height + 10
    
    totalCells = items.count
    // The number of items on screen is always an odd, because it helps to calculate frames of items more easier and cooler
    if totalCellOnScreen % 2 == 0 && totalCells > totalCellOnScreen {
      totalCellOnScreen -= 1
    }
    // CurrentIndex is presented for index of item at center of screen
    currentIndex = Int(totalCellOnScreen/2)
    index = currentIndex
    // Calculate frame of scrollview
    frame.origin.y = kNumberDefaultSpace
    frame.origin.x = isRight ? kNumberDefaultDistance : 0
    menusScrollView.frame = frame
  }
  
  /**
   Setup Menu at the screen right
   */
  private func setupMenusAtRight() {
    initialItems |> true
  }
  
  /**
   Setup Menu at the screen left
   */
  private func setupMenusAtLeft() {
    initialItems |> false
  }
  /**
   A common method that will helps to initialize side menu
   
   - parameter right: position of side menu
   */
  private func initialItems(right: Bool) {
    if items.count == 0 {
      return
    }
    if totalCells < 0 {
      return
    }
    for index in 0 ..< totalCells {
      // Calculate item frame by its index
      let dest = abs(index-currentIndex)
      let sum = (0..<dest).reduce(0, combine: { $0 + $1*kNumberAriProg })
      let originX = (right ? 1 : -1) * CGFloat(sum + kNumberDefaultItemsHoziConstant*dest)
      let itemFrame = CGRectMake(originX, CGFloat(index*Int(kNumberDefaultItemHeight)), menusScrollView.frame.size.width, kNumberDefaultItemHeight)
      
      // Initial item by index
      let itemView = LNItemView()
      itemView.setupView |> (itemFrame, items[index], index==indexOfCellHighlight, right, itemTitleColor, highlightItemColor, itemBackgroundColor)
      itemView.tag = index
      // add single tap gesture for each item of menu
      let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapContentView(_:)))
      tapGesture.numberOfTapsRequired = 1
      itemView.addGestureRecognizer |> tapGesture
      // Add item to scrollview
      self.menusScrollView.addSubview |> itemView
      // Cache list of items
      views.addObject |> itemView
    }
    menusScrollView.contentSize = CGSizeMake(menusScrollView.frame.size.width, CGFloat(totalCells*Int(kNumberDefaultItemHeight)))
    self.addSubview |> self.menusScrollView
  }
  
  // MARK: Action handler functions
  
  /**
   Change items frame when the user scrolling
   */
  private func animationToIndex(index: Int, animated: Bool) {
    
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
  private func getXpos(dest: Int) -> CGFloat {
    let cdest = dest < 0 ? 0 : dest
    let sum = (0..<cdest).reduce(0, combine: {$0 + $1*kNumberAriProg})
    let xpos = currentPosition == .Right ? CGFloat(sum + kNumberDefaultItemsHoziConstant*cdest) : -CGFloat(sum + kNumberDefaultItemsHoziConstant*cdest)
    return xpos
  }
  
  /**
   Update frame of current item by offset value
   */
  private func updateXpos(frame: CGRect, offset: CGFloat, dist: CGFloat, plus: Bool) -> CGRect {
    let num: CGFloat = plus ? 1 : -1
    var frame = frame
    frame.origin.x += (currentPosition == .Right ? num: -num) * (offset * dist / kNumberDefaultItemHeight)
    return frame
  }
  
  /**
   Update items frame by scrollview content offset
   */
  private func changeItemsFrameByOffset(scrollUp: Bool, offset: CGFloat, currentIndex: Int) {
    var currentViewIndex = 0
    for view in views {
      var dest = abs(currentViewIndex-currentIndex)
      if currentViewIndex <= currentIndex { dest += scrollUp ? 1 : -1 } else { dest -= scrollUp ? 1 : -1 }
      let xpos = self.getXpos(dest)
      let frame = view.frame
      let dist = abs(view.frame.origin.x - xpos)
      let plus = scrollUp ? currentViewIndex <= currentIndex : !(currentViewIndex <= currentIndex)
      (view as! LNItemView).frame = self.updateXpos(frame, offset: offset, dist: dist, plus: plus)
      currentViewIndex += 1
    }
  }
  
  /**
   Update item frame if it's current item
   */
  private func updateItemViewWidth(currentView: LNItemView, speed: CGFloat) {
    animateUpdateView { return 0 } |> (currentView, speed)
  }
  
  /**
   Update other items frame
   */
  private func updateItemViewFor(itemView: LNItemView, index: Int, current: Int, speed: CGFloat) {
    animateUpdateView { [unowned self] _ in
      let dest = abs(index-current)
      let sum = (0..<dest).reduce(0, combine: {$0 + $1*self.kNumberAriProg})
      let originX = self.currentPosition == .Right ? CGFloat(sum + 2*dest) : -CGFloat(sum + self.kNumberDefaultItemsHoziConstant*dest)
      return originX
    } |> (itemView, speed)
  }
  
  private func animateUpdateView<A: UIView>(calculateX: () -> CGFloat) -> (A, CGFloat) -> () {
    let xpos = calculateX()
    return { view, speed in
      UIView.animateWithDuration(NSTimeInterval(speed), delay: 0, options: .CurveLinear, animations: { () -> Void in
        view.frame.origin.x = xpos
        }, completion: nil)
      UIView.commitAnimations()
    }
  }
  
  // MARK: SideMenuDelegate
  /**
   Did tap on item handler
   */
  func didTapContentView(sender: UIGestureRecognizer) {
    let view = sender.view
    let index = view?.tag
    delegate?.didSelectItemAtIndex(SideMenu: self, index: index ?? 0)
    if highlightItemWhenDidTouch {
      if let label = currentItem?.viewWithTag(101) as? UILabel {
        label.textColor = itemTitleColor
      }
      if let currentLabel = view?.viewWithTag(101) as? UILabel {
        currentLabel.textColor = highlightItemColor
      }
      currentItem = view
    }
  }
  
  // MARK: UIScrollViewDelegate
  /**
   Handle scrolling and change items frame on the view
   */
  func scrollViewDidScroll(scrollView: UIScrollView) {
    
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
  
  private func clearDrawRect(rect: CGRect) {
    guard let context = UIGraphicsGetCurrentContext() else { return }
    CGContextClearRect(context, rect)
    CGContextClosePath(context)
  }
  
  /**
   Draw a shape with a curve line and 3 straight lines on the owner view
   */
  override  func drawRect(rect: CGRect) {
    guard let context = UIGraphicsGetCurrentContext() else { return }
    let size = rect.size
    CGContextSetStrokeColorWithColor(context, UIColor.clearColor().CGColor);
    CGContextSetLineWidth(context, 3)
    // Draw the polygon
    if currentPosition == .Left {
      self.drawShapeForLeftView(currentContext: context, size: size)
    } else {
      self.drawShapeForRightView(currentContext: context, size: size)
    }
    
    // Fill it
    CGContextSetFillColorWithColor(context, bgColor.CGColor)
    
    // Stroke it
    CGContextDrawPath(context, .FillStroke)
  }
  
  /**
   Draw a shape for left view, this func is called when the SideMenu on the screen left
   */
  private func drawShapeForLeftView(currentContext currentContext: CGContext, size: CGSize) {
    CGContextMoveToPoint(currentContext, 0, 0)
    CGContextAddLineToPoint(currentContext, size.width/2.4 ,0)
    CGContextAddQuadCurveToPoint(currentContext, size.width + size.width/2, size.height/2, size.width/2.4, size.height)
    CGContextAddLineToPoint(currentContext, 0, size.height) // base
    CGContextAddLineToPoint(currentContext, 0, 0); // right border
  }
  
  /**
   Draw a shape for right view, this func is called when the SideMenu on the screen right
   */
  private func drawShapeForRightView(currentContext currentContext: CGContext, size: CGSize) {
    CGContextMoveToPoint(currentContext, size.width, 0)
    CGContextAddLineToPoint(currentContext, size.width - size.width/2.4 ,0)
    CGContextAddQuadCurveToPoint(currentContext, -size.width/2, size.height/2, size.width - size.width/2.4, size.height)
    CGContextAddLineToPoint(currentContext, size.width, size.height) // base
    CGContextAddLineToPoint(currentContext, size.width, 0); // right border
  }
  
}
