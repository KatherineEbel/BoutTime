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
    // Dispose of any resources that can be recreated.
    print("Memory Warning")
  }
  
  
  @IBAction func getEvent1Info(_ sender: UITapGestureRecognizer) {
    getInfo(forEventIndex: 0)
  }
  @IBAction func getEvent2Info(_ sender: UITapGestureRecognizer) {
    getInfo(forEventIndex: 1)
  }
  @IBAction func getEvent3Info(_ sender: UITapGestureRecognizer) {
    getInfo(forEventIndex: 2)
  }
  @IBAction func getEvent4Info(_ sender: UITapGestureRecognizer) {
    getInfo(forEventIndex: 3)
  }
  
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
    let eventButtonTag = EventButtonTag(rawValue: sender.tag)
    if let eventButtonTag = eventButtonTag {
      activate(sender, forTag: eventButtonTag)
      let (oldIndex, newIndex) = indexesForEvent(withButtonTag: eventButtonTag)
      boutTimeGame.swapEvents(oldEventIndex: oldIndex, newEventIndex: newIndex)
      setUpEventLabels()
    }
    
  }
  
  func activate(_ button: UIButton, forTag tag: EventButtonTag) {
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
  
  override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
    let isCurrentRoundOver = boutTimeGame.currentRound.isOver
    if motion == .motionShake && !isCurrentRoundOver {
      print(isCurrentRoundOver)
      resultForRound()
      deselectEventButtons()
      eventButtonsEnabled(false)
      boutTimeGame.currentRound.roundOver()
    }
  }
  
  func setUpEventLabels() {
    let events = boutTimeGame.currentRound.events
    for (idx, label) in eventLabels.enumerated() {
      label.text = events[idx].name
    }
  }
  
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
  
  func setTimerLabel() {
    boutTimeGame.currentRound.timerLabel = self.timerLabel
    boutTimeGame.currentRound.startTimer()
  }
  
  func setupUIForResult(success: Bool) {
    let image: UIImage
    touchOnEventLabels(isEnabled: true)
    timerLabel.isHidden = true
    promptLabel.text = GamePrompt.tapToLearnMore.rawValue
    do {
      image = try UIImage.image(forEvent: .nextRound(success: success))
    } catch let error {
      print("Couldn't get image")
      fatalError("\(error)")
    }
    nextRoundButton.setImage(image, for: .normal)
    nextRoundButton.isHidden = false
  }
  
  func indexesForEvent(withButtonTag tag: EventButtonTag) -> (oldIndex: Int, newIndex: Int) {
    let indexes: (Int, Int)
    switch tag {
      case .event1Down: indexes = (0, 1)
      case .event2Up: indexes = (1, 0)
      case .event2Down: indexes = (1, 2)
      case .event3Up: indexes = (2, 1)
      case .event3Down: indexes = (2, 3)
      case .event4Up: indexes = (3, 2)
    }
    return indexes
  }
  
  func eventButtonsEnabled(_ enabled: Bool) {
    let isEnabled = enabled
    for eventButton in eventButtons {
      eventButton.isUserInteractionEnabled = isEnabled
    }
  }
  
  func deselectEventButtons() {
    for eventButton in eventButtons {
      let tag = EventButtonTag(rawValue: eventButton.tag)
      do {
        let image = try UIImage.imageForEventButton(withTag: tag!, isSelected: false)
        eventButton.setImage(image, for: .normal)
        eventButton.isUserInteractionEnabled = false
      } catch let error {
        fatalError("\(error)")
      }
    }
  }

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
        print(selectedEvent.urlString)
        infoController.infoUrlString = selectedEvent.urlString
      }
    } else if segue.identifier == SegueIdentifier.endGame.rawValue {
      let gameResultController = segue.destination as! GameResultController
      gameResultController.result = boutTimeGame.gameResult()
      boutTimeGame.endGame()
    }
  }
}

