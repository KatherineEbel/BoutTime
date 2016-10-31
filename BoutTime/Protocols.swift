//
//  Protocols.swift
//  BoutTime
//
//  Created by Katherine Ebel on 10/25/16.
//  Copyright © 2016 Katherine Ebel. All rights reserved.
//

import Foundation

protocol EventType {
  var name: String { get }
  var date: NSDate { get }
  var urlString: String { get }
  func isBefore(otherEvent event: EventType) -> Bool
}

protocol Timeable {
  var timeLimit: TimeInterval { get }
  var timer: Timer { get set }
  func stopTimer()
  func startTimer()
}

protocol Chronologicalizable {
  var events: [EventType] { get set }
  var isChronological: Bool { get }
}
