//
//  LNPanelViewController.swift
//  LNSideMenuEffect
//
//  Created by Luan Nguyen on 6/22/16.
//  Copyright © 2016 Luan Nguyen. All rights reserved.
//

import UIKit

public final class LNPanelViewController: UIViewController {
  
  // MARK: Properties
  fileprivate var items: [String] = []
  fileprivate var didInit = false
  weak var delegate: LNSMDelegate?
  var position: Position = .left
  var isNavigationBarChanged = false {
    didSet {
      updateFrame()
    }
  }
  // MARK: Colors
  open var menuBgColor = LNColor.bgView.color
  open var itemBgColor = LNColor.bgItem.color
  open var highlightColor = LNColor.highlight.color
  open var titleColor = LNColor.title.color
  
  lazy var sideMenuView: LNSideMenuView = LNSideMenuView()
  
  convenience init(items: Array<String>, menuPosition: Position, highlightCellAtIndex: Int = Int.max) {
    self.init()
    self.items = items
    self.position = menuPosition
    self.sideMenuView.indexOfDefaultCellHighlight = highlightCellAtIndex
  }
  
  override open func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.backgroundColor = .clear
    self.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
  }
  
  open override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if !didInit {
      didInit = true
      initialSideMenu()
    }
  }
  /**
   Initial side menu with components
   */
  fileprivate func initialSideMenu() {
    sideMenuView.items = items
    _ = setViewFrame()
    
    // Config colors
    sideMenuView.bgColor = menuBgColor
    sideMenuView.titleColor = titleColor
    sideMenuView.itemBgColor = itemBgColor
    sideMenuView.highlightColor = highlightColor
    
    // Setup menu
    sideMenuView.setupMenu |> (view, position)
    sideMenuView.delegate = self
  }
  
  internal func setViewFrame() -> Bool {
    // Set frame for view
    let distance: CGFloat = isNavigationBarChanged ? 0 : 64
    if view.y != distance {
      view.y = distance
      view.height = screenHeight - view.y
      return true
    }
    return false
  }
  
  internal func updateFrame() {
    // Just refresh side menu iff the view frame has already changed
    if setViewFrame() {
      sideMenuView.refreshMenuWithFrame |> (self.view.frame, isNavigationBarChanged)
    }
  }
  
  // Moving all items out of container view bounds before performing animation
  internal func prepareForAnimation() {
    sideMenuView.prepareForAnimation()
  }
  
  internal func animateContents(completion: @escaping Completion) {
    // Animate items when it's about diplayed
    sideMenuView.animateContents(completion: completion)
  }
  
  internal func transitionToView() {
    // TODO: implementing set contentViewController effection
  }
  
}

extension LNPanelViewController: LNSMDelegate {
  func didSelectItemAtIndex(SideMenu: LNSideMenuView, index: Int) {
    // Forward did select item at index action
    delegate?.didSelectItemAtIndex(SideMenu: SideMenu, index: index)
  }
}
