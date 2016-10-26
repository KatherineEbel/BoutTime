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
  case incorrectAnswer(GameSound)
  case correctAnswer(GameSound)
  case gameOver
  case nextRound
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

class BoutTimeRound: Timeable, Chronologicalizable {
  let eventsPerRound = 4
  var timeLimit: TimeInterval = 60
  var timer: Timer = Timer()
  var events: [EventType] = []
  var isChronological: Bool {
    for event in 0..<(events.count - 1) {
      if !events[event].isBefore(otherEvent: events[event + 1]) {
        return false
      }
    }
    return true
  }
  
  func startTimer() {
    timer = Timer.scheduledTimer(timeInterval: timeLimit, target: self, selector: Selector(("roundOver")), userInfo: nil, repeats: false)
  }
  
  func stopTimer() {
    timer.invalidate()
  }
  
  func roundOver() {
    print("Round Over!")
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
