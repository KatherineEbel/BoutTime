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
  @IBOutlet weak var timerLabel: UILabel!
  @IBOutlet weak var nextRoundButton: UIButton!

  
  
  let boutTimeGame = BoutTimeGame()
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
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "text" {
      guard let text = change?[.newKey] as? String else {
        return
      }
      if text == "0:00" {
        let success = isCurrentRoundChronological()
        boutTimeGame.result(forGameEvent: success ? .correctAnswer(sound: .CorrectDing): .incorrectAnswer(sound: .IncorrectBuzz))
        boutTimeGame.endRound(success: success)
        setupUIForResult(success: success)
      }
    }
  }
  
  override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
    if motion == .motionShake {
      let correct = boutTimeGame.currentRound.isChronological
      boutTimeGame.currentRound.roundOver()
      boutTimeGame.result(forGameEvent: correct ?
        .correctAnswer(sound: .CorrectDing) : .incorrectAnswer(sound: .IncorrectBuzz))
      boutTimeGame.endRound(success: correct)
      setupUIForResult(success: correct)
    }
  }
  func setUpEventLabels() {
    let events = boutTimeGame.currentRound.events
    for (idx, label) in eventLabels.enumerated() {
      label.text = events[idx].name
    }
  }
  
  func setupUI() {
    setUpEventLabels()
    setTimerLabel()
  }
  
  func setTimerLabel() {
    boutTimeGame.currentRound.timerLabel = self.timerLabel
    boutTimeGame.currentRound.startTimer()
  }
  
  func setupUIForResult(success: Bool) {
    let image: UIImage
    timerLabel.isHidden = true
    do {
      image = try UIImage.image(forResult: .nextRound(success: success))
    } catch let error {
      fatalError("\(error)")
    }
    nextRoundButton.setImage(image, for: .normal)
    nextRoundButton.isHidden = false
  }

  func roundEventLabelCorners() {
    for eventLabel in eventLabels {
      eventLabel.round(corners: [.bottomLeft, .topLeft], withRadius: 5.0)
    }
  }
  
  func isCurrentRoundChronological() -> Bool {
    return boutTimeGame.currentRound.isChronological
  }

}

