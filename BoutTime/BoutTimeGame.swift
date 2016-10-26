//
//  BoutTimeGame.swift
//  BoutTime
//
//  Created by Katherine Ebel on 10/25/16.
//  Copyright © 2016 Katherine Ebel. All rights reserved.
//

import Foundation
import AudioToolbox
import GameKit

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
  
  func start() {
    newRound()
    do {
      try loadGameSounds()
    } catch let error {
      fatalError("\(error)")
    }
  }
  
  func newRound() {
    currentRound = BoutTimeRound()
    getEventsForCurrentRound()
  }
  
  func getEventsForCurrentRound() {
    if let currentRound = currentRound {
      for _ in 1...currentRound.eventsPerRound {
        let event = getUniqueEvent(forRound: currentRound)
        currentRound.events.append(event)
      }
    }
  }
  
  func getUniqueEvent(forRound round: BoutTimeRound) -> EventType {
    let indexOfEvent = GKRandomSource.sharedRandom().nextInt(upperBound: self.events.count)
    var event: EventType
    var _ = round.events
    repeat {
      event = self.events[indexOfEvent]
    } while !events.contains(where: { (eventToCheck) -> Bool in
        eventToCheck.name == event.name
      })
    return event
  }
  
  func loadGameSounds() throws {
    for (name, _) in gameSounds {
      let soundURL: URL
      guard let pathToSoundFile = Bundle.main.path(forResource: name.rawValue, ofType: "wav") else {
        throw BoutTimeError.LoudSoundError
      }
      soundURL = URL(fileURLWithPath: pathToSoundFile)
      AudioServicesCreateSystemSoundID(soundURL as CFURL, &gameSounds[name]!)
    }
  }
  
  func play(sound: GameSound) {
    if let sound = gameSounds[sound] {
      AudioServicesPlaySystemSound(sound)
    }
  }
}
