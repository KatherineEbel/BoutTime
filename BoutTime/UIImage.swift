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
    case .gameOver: name = "play_again"
    default: name = "play_again"
    }
    guard let image = UIImage(named: name) else {
      print("Couldn't get image")
      throw ResourceError.InvalidResource
    }
    return image
  }
  
  class func imageForEventButton(withTag tag: EventButtonTag, isSelected: Bool) throws -> UIImage {
    var name: String
    switch tag {
      case .event1Down: name = "down_full"
      case .event2Up, .event3Up: name = "up_half"
      case .event2Down, .event3Down: name = "down_half"
      case .event4Up:  name = "up_full"
    }
    name += isSelected ? "_selected" : ""
    guard let image = UIImage(named: name) else {
      throw ResourceError.InvalidResource
    }
    return image
  }
}
