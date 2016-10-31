//
//  BoutTimeGame.swift
//  BoutTime
//
//  Created by Katherine Ebel on 10/25/16.
//  Copyright © 2016 Katherine Ebel. All rights reserved.
//

import Foundation
import AudioToolbox

class BoutTimeGame {
  var events: [EventType]
  var gameSounds: [GameSound: SystemSoundID] = [.CorrectDing: 0, .IncorrectBuzz: 0, .ButtonPress: 0]
  var currentRound: BoutTimeRound = BoutTimeRound()
  var roundsPerGame = 6
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
  
  // load sounds at start of game
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
    currentRound.getEvents(fromEvents: events)
  }
  
  // keeps events for round in sync with game play
  func swapEvents(forIndex oldIndex: Int, andIndex newIndex: Int) {
    currentRound.swapEvents(currentEventIndex: oldIndex, newEventIndex: newIndex)
  }
 
  // throws error if sound unable to load
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
  
  // play passed in sound
  func play(sound: GameSound) {
    if let sound = gameSounds[sound] {
      AudioServicesPlaySystemSound(sound)
    }
  }
  
  // increments number of rounds and adds to score if round ends with correct answer
  // if game not over start a new round
  func endRound(success: Bool) {
    if success {
      totalScore += 1
    }
    roundCounter += 1
    currentRound.end()
    if !isGameOver {
      newRound()
    }
  }
  
  // reset score at end of game
  func endGame() {
    totalScore = 0
    roundCounter = 0
  }
  
  // configure final score for display
  func gameResult() -> String {
    return "\(totalScore) / \(roundsPerGame)"
  }
}
