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

protocol EventType {
  var name: String { get }
  var date: NSDate { get }
}

protocol Timeable {
  var timeLimit: TimeInterval { get }
  var timer: Timer { get set }
  
  func stopTimer()
  func startTimer()
}

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

class BoutTimeRound: Timeable {
  var timeLimit: TimeInterval = 60
  var timer: Timer = Timer()
  var events: [EventType] = []
  let eventsPerRound = 4
  
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

class BoutTimeGame {
  var events: [EventType]
  var gameSounds: [GameSound: SystemSoundID] = [.CorrectDing: 0, .IncorrectBuzz: 0]
  var currentRound: BoutTimeRound?
  
  init() {
    do {
      let dictionary = try PlistConverter.dictionaryFromFile(resource: "Events", ofType: "plist")
      let events = try EventUnarchiver.eventsFromDictionary(dictionary: dictionary)
      self.events = events
    } catch let error {
      fatalError("\(error)")
    }
  }
  
  func start() throws {
    currentRound = BoutTimeRound()
    guard let events = eventsForCurrentRound(), let currentRound = currentRound else {
      throw BoutTimeError.StartRoundError
    }
    currentRound.events = events
  }
  
  func eventsForCurrentRound() -> [EventType]? {
    var events: [EventType]? = []
    if let currentRound = currentRound {
      for _ in 1...currentRound.eventsPerRound {
        let event = getUniqueEvent(forRound: currentRound)
        events?.append(event)
      }
    }
    return events ?? nil
  }
  
  func getUniqueEvent(forRound round: BoutTimeRound) -> EventType {
    let indexOfEvent = GKRandomSource.sharedRandom().nextInt(upperBound: self.events.count)
    var event: EventType
    var _ = round.events
    repeat {
      event = self.events[indexOfEvent]
    } while !events.contains(where: { (eventToCheck) -> Bool in
        eventToCheck.name != event.name
      })
    return event
  }
  
  func loadGameSounds() {
    for (name, _) in gameSounds {
      let pathToSoundFile: String?
      let soundURL: URL
      pathToSoundFile = Bundle.main.path(forResource: name.rawValue, ofType: "wav")
      if let pathToSoundFile = pathToSoundFile {
        soundURL = URL(fileURLWithPath: pathToSoundFile)
        AudioServicesCreateSystemSoundID(soundURL as CFURL, &gameSounds[name]!)
      }
    }
  }
  
  func play(sound: GameSound) {
    if let sound = gameSounds[sound] {
      AudioServicesPlaySystemSound(sound)
    }
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
