//
//  Event.swift
//  BoutTime
//
//  Created by Katherine Ebel on 10/25/16.
//  Copyright © 2016 Katherine Ebel. All rights reserved.
//

import UIKit
import AudioToolbox
import GameKit

enum GameSound: String {
  case IncorrectBuzz
  case CorrectDing
  case ButtonPress
}

enum GameEvent {
  case incorrectAnswer
  case correctAnswer
  case nextRound(success: Bool)
}

enum EventButtonTag: Int {
  case event1Down = 101
  case event2Up = 102
  case event2Down = 103
  case event3Up = 104
  case event3Down = 105
  case event4Up = 106
  
  var indexesForTag: (currentIndex: Int, newIndex: Int) {
    let indexes: (Int, Int)
    switch self {
    case .event1Down: indexes = (0, 1)
    case .event2Up: indexes = (1, 0)
    case .event2Down: indexes = (1, 2)
    case .event3Up: indexes = (2, 1)
    case .event3Down: indexes = (2, 3)
    case .event4Up: indexes = (3, 2)
    }
    return indexes
  }
}

// Prompt Labels for gameController
enum GamePrompt: String {
  case shakeToComplete = "Shake to complete"
  case tapToLearnMore = "Tap events to learn more"
}

// segue identifiers for viewControllers
enum SegueIdentifier: String {
  case startGame
  case getInfo
  case endGame
}

// event can determine if it comes before another event
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

// BoutTimeGame will have an instance of this class as a currentRound property
class BoutTimeRound: NSObject, Timeable, Chronologicalizable {
  let eventsPerRound = 4
  var isOver = false
  var timeLimit: TimeInterval = 60
  var timer: Timer = Timer()
  var events: [EventType] = []
  var currentEventIndexes: [Int] = []
  weak var timerLabel: UILabel?
  var timerCounter: Int = 60 {
    didSet {
      if let timerLabel = timerLabel {
        update(timerLabel: timerLabel, withCounter: timerCounter)
      }
    }
  }
  // calculates if events for round are chronological earliest to latest
  var isChronological: Bool {
    for event in 0..<(events.count - 1) {
      if !events[event].isBefore(otherEvent: events[event + 1]) {
        return false
      }
    }
    return true
  }
  
  // timer will call decrementCounter every second until invalidated by stopTimer()
  func startTimer() {
    timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(BoutTimeRound.decrementCounter), userInfo: nil, repeats: true)
  }
  
  func stopTimer() {
    timer.invalidate()
  }
  
  func decrementCounter() {
    timerCounter -= 1
    if timerCounter == 0 {
      end()
    }
  }
  
  // keeps the label's text synced with the counter
  func update(timerLabel label: UILabel, withCounter counter: Int) {
    let labelTitle = counter >= 10 ? "0:\(counter)" : "0:0\(counter)"
    timerLabel?.text = labelTitle
  }
  
  // stops timer and marks round as over
  func end() {
    stopTimer()
    isOver = true
  }
  
  // empty the rounds events, reset timerCounter and mark round not over
  func reset() {
    events = []
    timerCounter = 60
    isOver = false
  }
  
  // adds events for new round
  func getEvents(fromEvents events: [EventType]) {
    currentEventIndexes = []
    for _ in 0..<eventsPerRound {
      self.events.append(events[getUniqueIndexForEvent(withUpperBound: events.count)])
    }
  }
  
  // gets a random index to use that hasn't already been used for this round
  func getUniqueIndexForEvent(withUpperBound bound: Int) -> Int {
    var indexOfEvent: Int
    repeat {
      indexOfEvent = GKRandomSource.sharedRandom().nextInt(upperBound: bound)
    } while currentEventIndexes.contains(indexOfEvent)
    currentEventIndexes.append(indexOfEvent)
    return indexOfEvent
  }
  
  func swapEvents(currentEventIndex oldIndex: Int, newEventIndex newIndex: Int) {
    swap(&events[oldIndex], &events[newIndex])
  }
}


// convert a plist to a dictionary
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

// turn dictionary to an array of EventType
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
