//
//  DetailViewController.swift
//  NamesToFaces
//
//  Created by Mikhail Medvedev on 13.11.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//  swiftlint:disable prohibited_interface_builder

import UIKit

final class DetailViewController: UIViewController
{
	var imageName: String?
	@IBOutlet var imageView: UIImageView!

	override func viewDidLoad() {
		super.viewDidLoad()
		if let image = imageName {
			imageView.image = UIImage(contentsOfFile: image)
		}
	}
}
