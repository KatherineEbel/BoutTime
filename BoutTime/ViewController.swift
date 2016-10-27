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
  
  @IBAction func nextRound(_ sender: UIButton) {
    if boutTimeGame.isGameOver {
      boutTimeGame.endGame()
    } else {
      setupUI()
    }
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "text" {
      guard let text = change?[.newKey] as? String else {
        return
      }
      if text == "0:00" {
        endCurrentRound()
      }
    }
  }
  
  override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
    if motion == .motionShake {
      endCurrentRound()
    }
  }
  func setUpEventLabels() {
    let events = boutTimeGame.currentRound.events
    for (idx, label) in eventLabels.enumerated() {
      label.text = events[idx].name
    }
  }
  
  func endCurrentRound() {
    let isCorrectAnswer = boutTimeGame.currentRound.isChronological
    boutTimeGame.currentRound.roundOver()
    boutTimeGame.play(sound: isCorrectAnswer ? .CorrectDing : .IncorrectBuzz)
    boutTimeGame.endRound(success: isCorrectAnswer)
    setupUIForResult(success: isCorrectAnswer)
  }
  
  func setupUI() {
    print(boutTimeGame.currentRound.events.count)
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
}

