//
//  GameController.swift
//  BoutTime
//
//  Created by Katherine Ebel on 10/22/16.
//  Copyright © 2016 Katherine Ebel. All rights reserved.
//

import UIKit

class GameController: UIViewController {
 
  @IBOutlet var eventLabels: [UILabel]!
  @IBOutlet var eventButtons: [UIButton]!
  @IBOutlet weak var promptLabel: UILabel!
  @IBOutlet weak var timerLabel: UILabel!
  @IBOutlet weak var nextRoundButton: UIButton!

  let boutTimeGame: BoutTimeGame = BoutTimeGame()
  var selectedEvent: EventType? = nil
  var readyForNextRound = false
  override var canBecomeFirstResponder: Bool {
    return true
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    boutTimeGame.start()
    setupUI()
    self.becomeFirstResponder()
    timerLabel.addObserver(self, forKeyPath: "text", options: [.new], context: nil)
  }
  
  // sync timer starting when transitioning from gameResultController
  override func viewWillAppear(_ animated: Bool) {
    if readyForNextRound {
      boutTimeGame.newRound()
      setupUI()
      readyForNextRound = false
    }
  }
  
  override func viewWillLayoutSubviews() {
    roundEventLabelCorners()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // eventLabels are in sync with currentRound events, so get view associated
  // with tapGesture, find the tag and set the selectedEvent
  @IBAction func getEventInfo(_ sender: UITapGestureRecognizer) {
    if let view = sender.view as? UILabel,
      let index = eventLabels.index(of: view) {
      selectedEvent = boutTimeGame.currentRound.events[index]
      performSegue(withIdentifier: SegueIdentifier.getInfo.rawValue, sender: self)
    }
  }
  
  //ends current round and starts new one if game is not over
  @IBAction func nextRound(_ sender: UIButton) {
    readyForNextRound = true
    let isChronological = boutTimeGame.currentRound.isChronological
    boutTimeGame.endRound(success: isChronological)
    if boutTimeGame.isGameOver {
      performSegue(withIdentifier: SegueIdentifier.endGame.rawValue, sender: self)
    } else {
      setupUI()
      readyForNextRound = false
    }
  }
  
  
  @IBAction func swapEventsForSelectedButton(_ sender: UIButton) {
    boutTimeGame.play(sound: .ButtonPress)
    if let eventButtonTag = EventButtonTag(rawValue: sender.tag) {
      let (currentIndex, newIndex) = eventButtonTag.indexesForTag
      boutTimeGame.swapEvents(forIndex: currentIndex, andIndex: newIndex)
      setUpEventLabels()
    }
  }
  
  // observe value for timerLabel so view controller will know when timer is up
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "text" {
      guard let text = change?[.newKey] as? String else {
        return
      }
      if text == "0:00" {
        resultForRound()
      }
    }
  }
  
  // shakes shouldn't be detected while current round is over
  override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
    let isCurrentRoundOver = boutTimeGame.currentRound.isOver
    if motion == .motionShake && !isCurrentRoundOver {
      resultForRound()
      boutTimeGame.currentRound.end()
    }
  }
  
  // set eventLabel text to event titles in current round
  func setUpEventLabels() {
    let events = boutTimeGame.currentRound.events
    for (idx, label) in eventLabels.enumerated() {
      label.text = events[idx].name
    }
  }
  
  // checks if events are in chronological order, plays appropriate sound
  // calls for ui to be setup with result
  func resultForRound() {
    let isChronological = boutTimeGame.currentRound.isChronological
    boutTimeGame.play(sound: isChronological ? .CorrectDing : .IncorrectBuzz)
    setupUIForResult(success: isChronological)
  }
  
  // display appropriate UI objects for start of round, disable touch on eventLabels
  func setupUI() {
    timerLabel.isHidden = false
    nextRoundButton.isHidden = true
    promptLabel.text = GamePrompt.shakeToComplete.rawValue
    setUpEventLabels()
    eventButtonsEnabled(true)
    setTimerLabel()
    touchOnEventLabels(isEnabled: false)
  }
  
  // sets the viewController label to label for current round, so the label
  // will stay in sync with timer
  func setTimerLabel() {
    boutTimeGame.currentRound.timerLabel = self.timerLabel
    boutTimeGame.currentRound.startTimer()
  }
  
  // touch should be enabled for event labels at end of round, setup nextButton and prompt label
  func setupUIForResult(success: Bool) {
    let image: UIImage
    touchOnEventLabels(isEnabled: true)
    eventButtonsEnabled(false)
    timerLabel.isHidden = true
    promptLabel.text = GamePrompt.tapToLearnMore.rawValue
    do {
      image = try UIImage.image(forEvent: .nextRound(success: success))
    } catch let error {
      fatalError("\(error)")
    }
    nextRoundButton.setImage(image, for: .normal)
    nextRoundButton.isHidden = false
  }
  
  // reenable event buttons at start of new rounds
  func eventButtonsEnabled(_ isEnabled: Bool) {
    eventButtons.forEach { $0.isUserInteractionEnabled = isEnabled }
  }

  // UIView extension function to round only left corners of eventLabels
  func roundEventLabelCorners() {
    for eventLabel in eventLabels {
      eventLabel.round(corners: [.bottomLeft, .topLeft], withRadius: 5.0)
    }
  }

  // touch should only be enabled on labels after round is over
  func touchOnEventLabels(isEnabled enabled: Bool) {
    for eventlabel in eventLabels {
      eventlabel.isUserInteractionEnabled = enabled ? true : false
    }
  }
  
  // Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == SegueIdentifier.getInfo.rawValue {
      let infoController = segue.destination as! InfoController
      if let selectedEvent = selectedEvent {
        // selectedEvent's urlString passed to the infoController
        infoController.infoUrlString = selectedEvent.urlString
      }
    } else if segue.identifier == SegueIdentifier.endGame.rawValue {
      let gameResultController = segue.destination as! GameResultController
      // gameResult passed to the gameResultController
      gameResultController.result = boutTimeGame.gameResult()
      boutTimeGame.endGame()
    }
  }
}

