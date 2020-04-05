//
//  DetailViewController.swift
//  FlagsViewer
//
//  Created by Mikhail Medvedev on 16.10.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var selectedFlag: String?
    
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageView()
        navigationItem.largeTitleDisplayMode = .never
        title = selectedFlag?.dropLast(4).uppercased()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
    }
    
    func setupImageView() {
        guard let flag = selectedFlag else { return }
        imageView.image = UIImage(named: flag)
    }
    
    @objc func shareTapped() {
        guard let image = imageView.image?.pngData() else { return }
        guard let name = selectedFlag else {  return }
        let activity = UIActivityViewController(activityItems: [image, name], applicationActivities: [])
        present(activity, animated: true)
    }
}
