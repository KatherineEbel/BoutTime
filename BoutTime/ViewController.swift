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
  let boutTimeGame = BoutTimeGame()


  override func viewDidLoad() {
    super.viewDidLoad()
    boutTimeGame.start()
    setUpEventLabels()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func setUpEventLabels() {
    if let currentRound = boutTimeGame.currentRound {
      print(currentRound.isChronological)
      let events = currentRound.events
      for (idx, label) in eventLabels.enumerated() {
        label.text = events[idx].name
      }
    } else {
      print("Can't setup labels")
    }
  }


}

