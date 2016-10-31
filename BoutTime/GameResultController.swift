//
//  GameResultController.swift
//  BoutTime
//
//  Created by Katherine Ebel on 10/27/16.
//  Copyright © 2016 Katherine Ebel. All rights reserved.
//

import UIKit

class GameResultController: UIViewController {
  
  @IBOutlet weak var scoreLabel: UILabel!
  var result = ""
  

    override func viewDidLoad() {
        super.viewDidLoad()
        // result will be passed in from segue
        scoreLabel.text = result
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  @IBAction func playAgain() {
    dismiss(animated: true, completion: nil)
  }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      let gameController = segue.destination as! GameController
      // ready for next round tells gameController ok to start timer for new round
      gameController.readyForNextRound = true
    }

}
