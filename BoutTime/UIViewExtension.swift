//
//  UIViewExtension.swift
//  BoutTime
//
//  Created by Katherine Ebel on 10/26/16.
//  Copyright © 2016 Katherine Ebel. All rights reserved.
//

import UIKit

extension UIView {
  
  func round(corners: UIRectCorner, withRadius radius: CGFloat) {
    let maskPath = UIBezierPath(roundedRect: self.bounds,
                              byRoundingCorners: corners,
                              cornerRadii: CGSize(width: radius, height: radius))
    let maskLayer = CAShapeLayer()
    maskLayer.path = maskPath.cgPath
    self.layer.mask = maskLayer
  }
}
