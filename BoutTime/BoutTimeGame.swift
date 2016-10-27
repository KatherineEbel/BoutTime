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
  var events: [Event]
  var gameSounds: [GameSound: SystemSoundID] = [.CorrectDing: 0, .IncorrectBuzz: 0]
  var currentRound: BoutTimeRound = BoutTimeRound()
  var numberOfRounds = 5
  var roundCounter = 0
  var totalScore = 0
  var isGameOver: Bool {
    return roundCounter == numberOfRounds
  }
  
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
    currentRound.reset()
    do {
      currentRound.events = try getEventsForCurrentRound()
    } catch let error {
      fatalError("\(error)")
    }
  }
  
  func getEventsForCurrentRound() throws -> [Event] {
    var eventsForRound: [Event] = []
    for _ in 1...currentRound.eventsPerRound {
      let event = getUniqueEvent(forEvents: eventsForRound)
      eventsForRound.append(event)
    }
    guard eventsForRound.count == currentRound.eventsPerRound else {
      throw BoutTimeError.StartRoundError
    }
    return eventsForRound
  }
  
  func getUniqueEvent(forEvents roundEvents: [Event]) -> Event {
    let indexOfEvent = GKRandomSource.sharedRandom().nextInt(upperBound: events.count)
    var roundEvent: Event
    repeat {
      roundEvent = self.events[indexOfEvent]
    } while roundEvents.contains(roundEvent)
    return roundEvent
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
  
  func endRound(success: Bool) {
    if success {
      totalScore += 1
    }
    roundCounter += 1
    isGameOver ? endGame() : newRound()
  }
  
  func endGame() {
    print("Game Over")
    // FIXME: Implement way to finish game
  }
}
