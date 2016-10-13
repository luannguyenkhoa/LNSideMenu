//
//  ItemView.swift
//  SwiftExample
//
//  Created by Luan Nguyen on 6/22/16.
//  Copyright (c) 2015 luannguyen. All rights reserved.
//

import UIKit

internal final class LNItemView: UIView {
  
  fileprivate var titleLabel = UILabel()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  required internal init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  internal func setupView(_ frame: CGRect, title: String, isHighlight: Bool, isRight: Bool, textColor: UIColor, highlightTextColor: UIColor, backgroundColor: UIColor) {
    var customFrame = frame
    customFrame.y += 10
    customFrame.height = 40
    self.frame = customFrame
    self.backgroundColor = backgroundColor
    let corner: UIRectCorner = isRight ? [.topLeft, .bottomLeft]: [.topRight, .bottomRight]
    self.setCornerRadius(view: self, corner: corner, size: CGSize(width: 20, height: 20))
    
    titleLabel.textColor = isHighlight ? highlightTextColor : textColor
    titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 13)
    titleLabel.textAlignment = NSTextAlignment.right
    titleLabel.text = title
    var labelFrame = CGRect(x: 0, y: 0, width: customFrame.width-kDistanceItemToRight, height: customFrame.height)
    if isRight {
      labelFrame.x = kDistanceItemToRight
      titleLabel.textAlignment = NSTextAlignment.left
    }
    titleLabel.frame = labelFrame
    titleLabel.tag = 101
    self.addSubview(titleLabel)
  }
  
  fileprivate func setCornerRadius(view: UIView, corner: UIRectCorner, size: CGSize) {
    let maskPath = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corner, cornerRadii: size)
    let maskLayer = CAShapeLayer()
    maskLayer.frame = view.bounds
    maskLayer.path = maskPath.cgPath
    view.layer.mask = maskLayer
  }
}
