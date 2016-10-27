//
//  Protocols.swift
//  BoutTime
//
//  Created by Katherine Ebel on 10/25/16.
//  Copyright © 2016 Katherine Ebel. All rights reserved.
//

import Foundation

protocol EventType: Equatable {
  var name: String { get }
  var date: NSDate { get }
  var urlString: String { get }
}

protocol Timeable {
  var timeLimit: TimeInterval { get }
  var timer: Timer { get set }
  
  func stopTimer()
  func startTimer()
}

protocol Chronologicalizable {
  var events: [Event] { get set }
  var isChronological: Bool { get }
}
