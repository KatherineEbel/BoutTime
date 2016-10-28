//
//  InfoController.swift
//  BoutTime
//
//  Created by Katherine Ebel on 10/27/16.
//  Copyright © 2016 Katherine Ebel. All rights reserved.
//

import UIKit

class InfoController: UIViewController, UIWebViewDelegate {
  
  @IBOutlet weak var webView: UIWebView!
  @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
  @IBOutlet weak var spinnerContainer: UIView!
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  var infoUrlString: String? = nil

  override func viewDidLoad() {
    super.viewDidLoad()
    do {
      try loadInfoView(forUrlString: infoUrlString)
    } catch let error {
      fatalError("\(error.localizedDescription)")
    }
  }
  
  override func viewWillLayoutSubviews() {
    spinnerContainer.round(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], withRadius: 10.0)
  }
  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
  
  func webViewDidStartLoad(_ webView: UIWebView) {
    spinnerContainer.isHidden = false
    activitySpinner.startAnimating()
  }
  
  func webViewDidFinishLoad(_ webView: UIWebView) {
    spinnerContainer.isHidden = true
    activitySpinner.stopAnimating()
  }
  
  func loadInfoView(forUrlString string: String?) throws {
    guard let infoUrlString = infoUrlString,
      let requestUrl = URL(string: infoUrlString) else {
      throw BoutTimeError.InfoUrlError
    }
    let request = URLRequest(url: requestUrl)
    webView.loadRequest(request)
  }

  @IBAction func close() {
    webView.stopLoading()
    webView.delegate = nil
    dismiss(animated: true, completion: nil)
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
