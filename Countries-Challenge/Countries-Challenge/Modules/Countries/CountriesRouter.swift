//
//  CountriesRouter.swift
//  Countries-Challenge
//
//  Created by Mikhail Medvedev on 28.11.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

protocol IRoutable
{
	func showVC(with country: Country)
}

final class CountriesRouter
{
	weak var vc: CountriesTableViewController?
	private var factory: Factory

	init(factory: Factory) {
		self.factory = factory
	}
}

extension CountriesRouter: IRoutable
{
	func showVC(with country: Country) {
		let destinationVC = factory.createDetailCountryModule(country: country)
		vc?.navigationController?.pushViewController(destinationVC, animated: true)
	}
}
