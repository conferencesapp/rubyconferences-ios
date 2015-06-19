//
//  ConferenceViewController.swift
//  ConferencesApp
//
//  Created by Rashmi Yadav on 5/8/15.
//
//

import UIKit

class ConferenceViewController: UIViewController, UIWebViewDelegate{

    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
     var conferenceLink: String = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url: NSURL = NSURL(string: conferenceLink)!
        let request: NSURLRequest = NSURLRequest(URL: url)
        webView.loadRequest(request)
        webView.delegate = self
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView)  {
        activityIndicator.hidden = true
        activityIndicator.stopAnimating()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
