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
      print("Shaken")
      performSegue(withIdentifier: "startGame", sender: self)
    }
  }
  

  /*
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      // Get the new view controller using segue.destinationViewController.
      // Pass the selected object to the new view controller.
  }
  */

}
