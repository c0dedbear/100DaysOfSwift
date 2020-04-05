//
//  DetailViewController.swift
//  WhiteHousePetitions
//
//  Created by Mikhail Medvedev on 27.10.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
    
    var webView: WKWebView!
    var petition: Petition?
    
    override func loadView() {
        webView = WKWebView()
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        showHtml()
    }
    
    func showHtml() {
        guard let petition = petition else { return }
        
        let html = """
        <html>
        <head><link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        </head>
        <body><div class="alert alert-success" role="alert"><h4 class="alert-heading">Well done!</h4><p>\(petition.body)</p><hr><p class="mb-0">Votes: \(petition.signatureCount)</p></div><div class="card"><div class="card-body"></div></div>
        </body>
        </html>
        """
        
        webView.loadHTMLString(html, baseURL: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
