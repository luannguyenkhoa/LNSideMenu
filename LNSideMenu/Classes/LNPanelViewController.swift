//
//  LNPanelViewController.swift
//  LNSideMenuEffect
//
//  Created by Luan Nguyen on 6/22/16.
//  Copyright © 2016 Luan Nguyen. All rights reserved.
//

import UIKit

public class LNPanelViewController: UIViewController {
  
  private var items: [String] = []
  private var didInit = false
  weak var delegate: LNSMDelegate?
  var position: Position = .Left
  var isNavigationBarChanged = false {
    didSet {
      updateFrame()
    }
  }
  
  public var menuBackgroundColor = LNDefaultColor.BackgroundColor.color()
  public var itemBGColor = LNDefaultColor.ItemBackgroundColor.color()
  public var highlightItemColor = LNDefaultColor.HighlightItem.color()
  public var itemTitleColor = LNDefaultColor.ItemTitleColor.color()
  
  lazy var sideMenuView: LNSideMenuView = LNSideMenuView()
  
  convenience init(items: Array<String>, menuPosition: Position, highlightCellAtIndex: Int = Int.max) {
    self.init()
    self.items = items
    self.position = menuPosition
    self.sideMenuView.indexOfDefaultCellHighlight = highlightCellAtIndex
  }
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.backgroundColor = .clearColor()
    self.view.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
  }
  
  public override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    initialSideMenu()
  }
  /**
   Initial side menu with components
   */
  private func initialSideMenu() {
    sideMenuView.items = items
    setViewFrame()
    
    // Config colors
    sideMenuView.bgColor = menuBackgroundColor
    sideMenuView.itemTitleColor = itemTitleColor
    sideMenuView.itemBackgroundColor = itemBGColor
    sideMenuView.highlightItemColor = highlightItemColor
    
    // Setup menu
    sideMenuView.setupMenu |> (view, position)
    sideMenuView.delegate = self
  }
  
  func setViewFrame() -> Bool {
    // Set frame for view
    let distance: CGFloat = isNavigationBarChanged ? 0 : 64
    if view.frame.origin.y != distance {
      view.frame.origin.y = distance
      view.frame.size.height = screenHeight - view.frame.origin.y
      return true
    }
    return false
  }
  
  func updateFrame() {
    // Just refresh side menu iff the view frame has already changed
    if setViewFrame() {
      sideMenuView.refreshMenuWithFrame |> (self.view.frame, isNavigationBarChanged)
    }
  }
  
}

extension LNPanelViewController: LNSMDelegate {
  func didSelectItemAtIndex(SideMenu SideMenu: LNSideMenuView, index: Int) {
    // Forward did select item at index action
    delegate?.didSelectItemAtIndex(SideMenu: SideMenu, index: index)
  }
}
