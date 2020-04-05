//
//  CountriesPresenter.swift
//  Countries-Challenge
//
//  Created by Mikhail Medvedev on 28.11.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit
import SDWebImage

protocol ICountriesPresentable
{
	func getCountriesCount() -> Int
	func getCountry(ofIndex: Int) -> Country
	func fetchCountries()
	func setImageToCell(of countryIndex: Int, cell: UITableViewCell)
	func onCellPressed(index: Int)
}

final class CountriesPresenter
{
	private var countriesRepository: ICountriesRepository
	private var router: IRoutable
	weak var tableVC: CountriesTableViewController?

	private var countries = [Country]()

	init(repository: ICountriesRepository, router: IRoutable) {
		self.countriesRepository = repository
		self.router = router
	}
}

extension CountriesPresenter: ICountriesPresentable
{
	func setImageToCell(of countryIndex: Int, cell: UITableViewCell) {
		guard cell.imageView != nil else { return }
		guard let svgURL = URL(string: countries[countryIndex].flag) else { return }
		let sVGImageSize = CGSize(width: 54, height: 44)
		cell.imageView?.sd_imageIndicator = SDWebImageActivityIndicator.gray
		cell.imageView?.sd_setImage(with: svgURL,
		placeholderImage: UIImage(),
		options: [.progressiveLoad],
		context: [.svgPrefersBitmap: true, .svgImageSize: sVGImageSize], progress: nil,
		completed: { _, _, _, _ in
			DispatchQueue.main.async {
				 cell.setNeedsLayout()
			}
		})
	}

	func fetchCountries() {
		countriesRepository.remoteDataSource.fetchCountries { result in
			switch result {
			case .success(let countries):
				self.countries = countries
				DispatchQueue.main.async { [weak self] in
					self?.tableVC?.tableView.reloadData()
				}
			case .failure:
				print("Failed to fetch countries")
			}
		}
	}

	func getCountriesCount() -> Int {
		countries.count
	}

	func getCountry(ofIndex: Int) -> Country {
		countries[ofIndex]
	}

	func onCellPressed(index: Int) {
		router.showVC(with: countries[index])
	}
}
