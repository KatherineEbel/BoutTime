//
//  UIButtonExtension.swift
//  BoutTime
//
//  Created by Katherine Ebel on 10/26/16.
//  Copyright © 2016 Katherine Ebel. All rights reserved.
//

import UIKit

extension UIImage {
  class func image(forResult result: GameEvent) throws -> UIImage {
    let name: String
    switch result {
    case .nextRound(success: let success):
      name = success ? "next_round_success" : "next_round_fail"
    default: name = "play_again"
    }
    guard let image = UIImage(named: name) else {
      throw ResourceError.InvalidResource
    }
    return image
  }
}
