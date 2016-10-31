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
    boutTimeGame.newRound()
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
  // with tapGesture, find the tag and get call get info for index associated with tag
  @IBAction func getEventInfo(_ sender: UITapGestureRecognizer) {
    if let view = sender.view as? UILabel,
      let index = eventLabels.index(of: view) {
      getInfo(forEventIndex: index)
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
    if let eventButtonTag = EventButtonTag(rawValue: sender.tag) {
      setActiveImage(forButton: sender)
      let (oldIndex, newIndex) = eventButtonTag.indexesForTag
      boutTimeGame.swapEvents(forIndex: newIndex, andIndex: oldIndex)
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
      deselectEventButtons()
      eventButtonsEnabled(false)
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
  func eventButtonsEnabled(_ enabled: Bool) {
    let isEnabled = enabled
    for eventButton in eventButtons {
      eventButton.isUserInteractionEnabled = isEnabled
    }
  }
  
  // changes event button image back to unselected image
  // buttons should also not be enabled for touch since round
  // will be over when this is called.
  func deselectEventButtons() {
    for eventButton in eventButtons {
      if let tag = EventButtonTag(rawValue: eventButton.tag) {
        do {
          // UIImage extension to set button image for selected or not selected
          let unselectedImage = try UIImage.imageForEventButton(withTag: tag, isSelected: false)
          eventButton.setImage(unselectedImage, for: .normal)
          eventButton.isUserInteractionEnabled = false
        } catch let error {
          fatalError("\(error)")
        }
      }
    }
  }
  
  // sets an individual button to a selected image state, and sets all others with unselected image
  func setActiveImage(forButton button: UIButton) {
    if let tag = EventButtonTag(rawValue: button.tag) {
      do {
        try button.setImage(UIImage.imageForEventButton(withTag: tag, isSelected: true), for: .normal)
        for eventButton in eventButtons {
          if eventButton.tag != tag.rawValue {
            let unselectedTag = EventButtonTag(rawValue: eventButton.tag)
            if let unselectedTag = unselectedTag {
              let image = try UIImage.imageForEventButton(withTag: unselectedTag, isSelected: false)
              eventButton.setImage(image, for: .normal)
            }
          }
        }
      } catch let error {
        fatalError("\(error)")
      }
    }

  }

  // UIView extension function to round only left corners of eventLabels
  func roundEventLabelCorners() {
    for eventLabel in eventLabels {
      eventLabel.round(corners: [.bottomLeft, .topLeft], withRadius: 5.0)
    }
  }
  
  // stop round timer and load info for the selected event
  func getInfo(forEventIndex index: Int) {
    selectedEvent = boutTimeGame.currentRound.events[index]
    performSegue(withIdentifier: SegueIdentifier.getInfo.rawValue, sender: self)
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
        infoController.infoUrlString = selectedEvent.urlString
      }
    } else if segue.identifier == SegueIdentifier.endGame.rawValue {
      let gameResultController = segue.destination as! GameResultController
      gameResultController.result = boutTimeGame.gameResult()
      boutTimeGame.endGame()
    }
  }
}

