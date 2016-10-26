//
//  Event.swift
//  BoutTime
//
//  Created by Katherine Ebel on 10/25/16.
//  Copyright © 2016 Katherine Ebel. All rights reserved.
//

import UIKit
import AudioToolbox

enum GameSound: String {
  case IncorrectBuzz
  case CorrectDing
}

enum GameEvent {
  case incorrectAnswer(sound: GameSound)
  case correctAnswer(sound: GameSound)
  case gameOver
  case nextRound(success: Bool)
}

enum EventButtonTag: Int {
  case event1Down = 101
  case event2Up = 102
  case event2Down = 103
  case event3Up = 104
  case event3Down = 105
  case event4Down = 106
}

struct Event: EventType {
  let name: String
  let date: NSDate
  let urlString: String
  
  func isBefore(otherEvent event: EventType) -> Bool {
    let earlierDate = date.earlierDate(event.date as Date)
    // if earlier date is equal to self.date then self is earlier than event argument
    return date as Date == earlierDate ? true : false
  }
}

class BoutTimeRound: NSObject, Timeable, Chronologicalizable {
  let eventsPerRound = 4
  var isComplete = false
  var timeLimit: TimeInterval = 60
  var timer: Timer = Timer()
  var events: [EventType] = []
  weak var timerLabel: UILabel?
  var timerCounter: Int = 60 {
    didSet {
      if let timerLabel = timerLabel {
        update(timerLabel: timerLabel, withCounter: timerCounter)
      }
    }
  }
  var isChronological: Bool {
    for event in 0..<(events.count - 1) {
      if !events[event].isBefore(otherEvent: events[event + 1]) {
        return false
      }
    }
    return true
  }
  
  func startTimer() {
    isComplete = false
    timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(BoutTimeRound.decrementCounter), userInfo: nil, repeats: true)
  }
  
  func stopTimer() {
    timer.invalidate()
  }
  
  func decrementCounter() {
    timerCounter -= 1
    if timerCounter == 0 {
      roundOver()
    }
  }
  
  func update(timerLabel label: UILabel, withCounter counter: Int) {
    label.text = counter >= 10 ? "0:\(counter)" : "0:0\(counter)"
  }
  
  func roundOver() {
    isComplete = true
    stopTimer()
  }
  
  deinit {
    print("Current Round deinit")
    timerLabel = nil
  }
}


class PlistConverter {
  class func dictionaryFromFile(resource: String, ofType type: String) throws -> [String: AnyObject] {
    guard let path = Bundle.main.path(forResource: resource, ofType: type) else {
      throw ResourceError.InvalidResource
    }
    
    guard let dictionary = NSDictionary.init(contentsOfFile: path),
    let castDictionary = dictionary as? [String: AnyObject] else {
      throw ResourceError.ConversionError
    }
    return castDictionary
  }
}

class EventUnarchiver {
  class func eventsFromDictionary(dictionary: [String: AnyObject]) throws -> [EventType] {
    var events: [EventType] = []
    for (_, value) in dictionary {
      if let eventDict = value as? [String: AnyObject],
        let name = eventDict["name"] as? String, let date = eventDict["date"] as? NSDate,
        let infoUrlString = eventDict["infoUrlString"] as? String {
        let event  = Event(name: name, date: date, urlString: infoUrlString)
        events.append(event)
      } else {
        throw ResourceError.ConversionError
      }
    }
    return events
  }
}
