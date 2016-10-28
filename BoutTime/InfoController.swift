//
//  InfoController.swift
//  BoutTime
//
//  Created by Katherine Ebel on 10/27/16.
//  Copyright © 2016 Katherine Ebel. All rights reserved.
//

import UIKit

class InfoController: UIViewController {
  
  @IBOutlet weak var webView: UIWebView!
  var infoUrlString: String? = nil

    override func viewDidLoad() {
      super.viewDidLoad()
      do {
        try loadInfoView(forUrlString: infoUrlString)
      } catch let error {
        fatalError("\(error.localizedDescription)")
      }
    }
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  func loadInfoView(forUrlString string: String?) throws {
    guard let infoUrlString = infoUrlString,
      let requestUrl = URL(string: infoUrlString) else {
      throw BoutTimeError.InfoUrlError
    }
    print(infoUrlString)
    let request = URLRequest(url: requestUrl)
    webView.loadRequest(request)
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
