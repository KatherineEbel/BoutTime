//
//  UIButtonExtension.swift
//  BoutTime
//
//  Created by Katherine Ebel on 10/26/16.
//  Copyright © 2016 Katherine Ebel. All rights reserved.
//

import UIKit

extension UIImage {
  class func image(forEvent event: GameEvent) throws -> UIImage {
    let name: String
    switch event {
    case .nextRound(success: let success):
      name = success ? "next_round_success" : "next_round_fail"
    default: name = "play_again"
    }
    guard let image = UIImage(named: name) else {
      print("Couldn't get image")
      throw ResourceError.InvalidResource
    }
    return image
  }
}
