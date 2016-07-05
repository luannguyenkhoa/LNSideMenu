//
//  ItemView.swift
//  SwiftExample
//
//  Created by Luan Nguyen on 6/22/16.
//  Copyright (c) 2015 luannguyen. All rights reserved.
//

import UIKit

internal class LNItemView: UIView {
  
  private var titleLabel = UILabel()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  required internal init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  internal func setupView(frame: CGRect, title: String, isHighlight: Bool, isRight: Bool, textColor: UIColor, highlightTextColor: UIColor, backgroundColor: UIColor) {
    var customFrame = frame
    customFrame.origin.y += 10
    customFrame.size.height = 40
    self.frame = customFrame
    self.backgroundColor = backgroundColor
    let corner: UIRectCorner = isRight ? [.TopLeft, .BottomLeft]: [.TopRight, .BottomRight]
    self.setCornerRadius(view: self, corner: corner, size: CGSizeMake(20, 20))
    
    titleLabel.textColor = isHighlight ? highlightTextColor : textColor
    titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 13)
    titleLabel.textAlignment = NSTextAlignment.Right
    titleLabel.text = title
    var labelFrame = CGRectMake(0, 0, customFrame.size.width-18, customFrame.size.height)
    if isRight {
      labelFrame.origin.x = 18
      titleLabel.textAlignment = NSTextAlignment.Left
    }
    titleLabel.frame = labelFrame
    titleLabel.tag = 101
    self.addSubview(titleLabel)
  }
  
  private func setCornerRadius(view view: UIView, corner: UIRectCorner, size: CGSize) {
    let maskPath = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corner, cornerRadii: size)
    let maskLayer = CAShapeLayer()
    maskLayer.frame = view.bounds
    maskLayer.path = maskPath.CGPath
    view.layer.mask = maskLayer
  }
}
