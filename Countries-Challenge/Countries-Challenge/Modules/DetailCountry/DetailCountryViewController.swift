//
//  DetailCountryViewController.swift
//  Countries-Challenge
//
//  Created by Mikhail Medvedev on 28.11.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit
import SDWebImage
import SDWebImageSVGCoder

final class DetailCountryViewController: UIViewController
{
	 var imageView = UIImageView()
	 var nameLabel = UILabel()
	 var descriptionLabel = UILabel()

	 var presenter: IDetailPresentable

	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = .white
		addSubViews()
		setConstratints()
	}

	private func addSubViews() {
		let country = presenter.getCountry()

		if let url = URL(string: country.flag) {
		let sVGImageSize = CGSize(width: 512, height: 384)
		imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
		imageView.sd_setImage(with: url,
		placeholderImage: UIImage(),
		options: [.progressiveLoad],
		context: [.svgPrefersBitmap: true, .svgImageSize: sVGImageSize], progress: nil,
		completed: { _, _, _, _ in
			DispatchQueue.main.async { [ weak self] in
				self?.imageView.setNeedsLayout()
			}
		})
		}
		view.addSubview(imageView)

		nameLabel.numberOfLines = 1
		view.addSubview(nameLabel)

		descriptionLabel.numberOfLines = 0
		view.addSubview(descriptionLabel)

		nameLabel.text = country.name
		descriptionLabel.text = """
		Capital: \(country.capital),
		Region: \(country.region),
		Population: \(country.population)
		"""
	}

	private func setConstratints() {
		imageView.translatesAutoresizingMaskIntoConstraints = false
		nameLabel.translatesAutoresizingMaskIntoConstraints = false
		descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
			imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
			imageView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 3 / 4),
			imageView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 1 / 3),

			nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
			nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
			nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),

			descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
			descriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
			descriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
			descriptionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
		])
	}

	init(presenter: IDetailPresentable) {
		self.presenter = presenter
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		print("DetailCountryViewController", #line, #function, Date())
	}
}
