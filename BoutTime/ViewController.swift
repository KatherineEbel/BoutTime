//
//  ViewController.swift
//  BoutTime
//
//  Created by Katherine Ebel on 10/22/16.
//  Copyright © 2016 Katherine Ebel. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
 
  @IBOutlet var eventLabels: [UILabel]!
  @IBOutlet var eventButtons: [UIButton]!
  
  @IBOutlet weak var timerLabel: UILabel!
  @IBOutlet weak var nextRoundButton: UIButton!

  let boutTimeGame: BoutTimeGame
  
  required init?(coder aDecoder: NSCoder) {
    boutTimeGame = BoutTimeGame()
    super.init(coder: aDecoder)
  }
  override var canBecomeFirstResponder: Bool {
    return true
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.becomeFirstResponder()
    boutTimeGame.start()
    timerLabel.addObserver(self, forKeyPath: "text", options: [.new], context: nil)
    setupUI()
  }
  
  override func viewWillLayoutSubviews() {
    roundEventLabelCorners()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
    print("Memory Warning")
  }
  
  @IBAction func nextRound(_ sender: UIButton) {
    if boutTimeGame.isGameOver {
      boutTimeGame.endGame()
    } else {
      setupUI()
    }
  }
  @IBAction func swapEventsForAction(_ sender: UIButton) {
    let eventButtonTag = EventButtonTag(rawValue: sender.tag)
    if let eventButtonTag = eventButtonTag {
      let (oldIndex, newIndex) = indexesForEvent(withButtonTag: eventButtonTag)
      boutTimeGame.swapEvents(oldEventIndex: oldIndex, newEventIndex: newIndex)
      setUpEventLabels()
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
    if motion == .motionShake {
      resultForRound()
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
    setUpEventLabels()
    setTimerLabel()
  }
  
  func setTimerLabel() {
    boutTimeGame.currentRound.timerLabel = self.timerLabel
    boutTimeGame.currentRound.startTimer()
  }
  
  func setupUIForResult(success: Bool) {
    print("setting up for result")
    let image: UIImage
    timerLabel.isHidden = true
    do {
      image = try UIImage.image(forResult: .nextRound(success: success))
    } catch let error {
      print("Couldn't get image")
      fatalError("\(error)")
    }
    nextRoundButton.setImage(image, for: .normal)
    nextRoundButton.isHidden = false
    boutTimeGame.endRound(success: success)
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

  func roundEventLabelCorners() {
    for eventLabel in eventLabels {
      eventLabel.round(corners: [.bottomLeft, .topLeft], withRadius: 5.0)
    }
  }
}

