//
//  DetailViewController.swift
//  StormViewer
//
//  Created by Mikhail Medvedev on 10.10.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    var selectedImageName: String?
	var viewsLabel = UILabel()
	var viewCount = 0 {
		didSet {
			saveViewsToDefaults()
			viewsLabel.text = "Views: \(viewCount)"
		}
	}
    var descriptionForTitle: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let name = selectedImageName,
           let descr = descriptionForTitle {
            title = descr
            imageView.image = UIImage(named: name)
        }
		viewsLabel.text = "Views: \(viewCount)"
		loadViewsToDefaults()
		navigationItem.rightBarButtonItem = UIBarButtonItem(customView: viewsLabel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
				viewCount += 1
        navigationController?.hidesBarsOnTap = true
        navigationItem.largeTitleDisplayMode = .never
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
        
    }

	private func saveViewsToDefaults() {
		let defaults = UserDefaults.standard
		defaults.set(viewCount, forKey: "viewCount\(selectedImageName ?? "0")")
	}

	private func loadViewsToDefaults() {
		let defaults = UserDefaults.standard
		viewCount = defaults.integer(forKey: "viewCount\(selectedImageName ?? "0")")
	}
}
