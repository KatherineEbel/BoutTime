//
//  InstructionsController.swift
//  BoutTime
//
//  Created by Katherine Ebel on 10/26/16.
//  Copyright © 2016 Katherine Ebel. All rights reserved.
//

import UIKit

class InstructionsController: UIViewController {
  
  override var canBecomeFirstResponder: Bool {
    return true
  }

  override func viewDidLoad() {
      super.viewDidLoad()
      self.becomeFirstResponder()
      // Do any additional setup after loading the view.
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
  
  override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
    if motion == .motionShake {
      performSegue(withIdentifier: SegueIdentifier.startGame.rawValue, sender: self)
    }
  }
}
