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
    var descriptionForTitle: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let name = selectedImageName,
           let descr = descriptionForTitle {
            title = descr
            imageView.image = UIImage(named: name)
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
        navigationItem.largeTitleDisplayMode = .never
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
        
    }
    
    @objc func shareTapped() {
        guard let image = imageView.image?.jpegData(compressionQuality: 0.8) else { return }
        guard let imageName = selectedImageName else { return }
        let activityVC = UIActivityViewController(activityItems: [image, imageName], applicationActivities: [])
        
        activityVC.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(activityVC, animated: true)
    }
}
