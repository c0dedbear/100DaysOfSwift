//
//  ViewController.swift
//  EasyBrowser
//
//  Created by Mikhail Medvedev on 17.10.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
    
    var webView = WKWebView()
    
    let websites = ["apple.com", "hackingwithswift.com", "twitter.com"]
    
    var progressView: UIProgressView!
    var textField: UITextField!
    
    override func loadView() {
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "https://" + websites[0])!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        setupTextField()
        setupBars()
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
    
    @objc func openTapped() {
        let ac = UIAlertController(title: "Open...", message: nil, preferredStyle: .actionSheet)
        
        for website in websites {
            ac.addAction(UIAlertAction(title: website, style: .default, handler: openPage))
        }
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    func openPage(action: UIAlertAction) {
        guard let title = action.title else { return }
        guard let url = URL(string: "https://" + title) else { return }
        webView.load(URLRequest(url: url))
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        textField.text = ""
        title = webView.title
        
    }
    
    func setupTextField() {
        textField = UITextField()
        textField.placeholder = "enter a url"
    }
    
    func setupBars() {
        
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.sizeToFit()
        
        //TODO: ADD CONSTRAINTS
        navigationController?.view.insertSubview(progressView, belowSubview: navigationController!.navigationBar)
        

        
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action:#selector(webView.reload))
        
        let backButton = UIBarButtonItem(barButtonSystemItem: .rewind, target: webView, action: #selector(webView.goBack))
        let forwardButton = UIBarButtonItem(barButtonSystemItem: .fastForward, target: webView, action: #selector(webView.goForward))
        
        //toolbarItems = [progressButton]
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: .actions, style: .plain, target: self, action: #selector(openTapped)), refreshButton]
        
        navigationItem.leftBarButtonItems = [backButton, forwardButton, UIBarButtonItem(customView: textField)]
        
        //navigationController?.isToolbarHidden = false
    }
    
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url
        
        let ac = UIAlertController(title: "Error", message: "This url isn't allowed", preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "OK", style: .default)
        ac.addAction(actionOk)
        
        //allow to visit only allowed urls
        if let host = url?.host {
            for website in websites {
                if host.contains(website) {
                    decisionHandler(.allow)
                    return
                }
            }
        }
        
        decisionHandler(.cancel)
    }
    
}

