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
  var currentRoundEventIndexes: [Int] = []
  var roundsPerGame = 5
  var roundCounter = 0
  var totalScore = 0
  var isGameOver: Bool {
    return roundCounter == roundsPerGame
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
    do {
      try loadGameSounds()
    } catch let error {
      fatalError("\(error)")
    }
  }
  
  func newRound() {
    currentRound.reset()
    currentRound.events = getEventsForCurrentRound()
  }
  
  func getEventsForCurrentRound() -> [EventType] {
    currentRoundEventIndexes = []
    var eventsForRound: [EventType] = []
    for _ in 0..<currentRound.eventsPerRound {
      eventsForRound.append(events[getUniqueIndexForEvent()])
    }
    return eventsForRound
  }
  
  func getUniqueIndexForEvent() -> Int {
    var indexOfEvent: Int
    repeat {
      indexOfEvent = GKRandomSource.sharedRandom().nextInt(upperBound: events.count)
    } while currentRoundEventIndexes.contains(indexOfEvent)
    currentRoundEventIndexes.append(indexOfEvent)
    return indexOfEvent
  }
  
  func swapEvents(oldEventIndex oldIndex: Int, newEventIndex newIndex: Int) {
    swap(&currentRound.events[oldIndex], &currentRound.events[newIndex])
  }
 
  func loadGameSounds() throws {
    for (name, _) in gameSounds {
      let soundURL: URL
      guard let pathToSoundFile = Bundle.main.path(forResource: name.rawValue, ofType: "wav") else {
        throw BoutTimeError.LoadSoundError
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
    currentRound.roundOver()
    if !isGameOver {
      newRound()
    }
  }
  
  func endGame() {
    totalScore = 0
    roundCounter = 0
  }
  
  func gameResult() -> String {
    return "\(totalScore) / \(roundsPerGame)"
  }
}
