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
    if roundCounter > 1 {
      currentRound = BoutTimeRound()
    }
    roundCounter += 1
    getEventsForCurrentRound()
  }
  
  func getEventsForCurrentRound() {
    for _ in 1...currentRound.eventsPerRound {
      let event = getUniqueEvent(forRound: currentRound)
      currentRound.events.append(event)
    }
  }
  
  func getUniqueEvent(forRound round: BoutTimeRound) -> EventType {
    let indexOfEvent = GKRandomSource.sharedRandom().nextInt(upperBound: events.count)
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
  
  func result(forGameEvent event: GameEvent) {
    switch event {
    case .correctAnswer(sound: let correctSound):  play(sound: correctSound)
    case .incorrectAnswer(sound: let incorrectSound): play(sound: incorrectSound)
    case .nextRound(success: let success): endRound(success: success)
    case .gameOver: endGame()
    }
  }
  
  func endRound(success: Bool) {
    if success {
      totalScore += 1
    }
    isGameOver ? result(forGameEvent: .gameOver) : newRound()
  }
  
  func endGame() {
    // FIXME: Implement way to finish game
  }
}
