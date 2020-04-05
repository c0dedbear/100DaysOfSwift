//
//  CountriesTableViewController.swift
//  Countries-Challenge
//
//  Created by Mikhail Medvedev on 28.11.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit
import SDWebImage
import SDWebImageSVGCoder

final class CountriesTableViewController: UITableViewController
{
	var presenter: ICountriesPresentable

	override func viewDidLoad() {
		super.viewDidLoad()
		presenter.fetchCountries()
		navigationController?.navigationBar.prefersLargeTitles = true
		title = "Countries"
	}

	init(presenter: ICountriesPresentable) {
		self.presenter = presenter
		super.init(style: .plain)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewWillLayoutSubviews() {
			view.frame = UIScreen.main.bounds
	}
}

extension CountriesTableViewController
{
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		presenter.getCountriesCount()
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(
			style: .subtitle,
			reuseIdentifier: "Cell")

		let contact = presenter.getCountry(ofIndex: indexPath.row)

		cell.textLabel?.text = contact.name
		cell.detailTextLabel?.text = "Capital: \(contact.capital), Population: \(contact.population)"

		cell.imageView?.backgroundColor = UIColor(white: 0.5, alpha: 0.1)
		presenter.setImageToCell(of: indexPath.row, cell: cell)

		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		presenter.onCellPressed(index: indexPath.row)
	}
}
