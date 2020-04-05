//
//  Factory.swift
//  Countries-Challenge
//
//  Created by Mikhail Medvedev on 28.11.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import Foundation

final class Factory
{
	func createCountriesModule() -> CountriesTableViewController {
		let remoteDataSource = NetworkService()
		let repository = CountriesRepository(remoteDataSource: remoteDataSource)
		let router = CountriesRouter(factory: self)
		let presenter = CountriesPresenter(repository: repository, router: router)
		let tableVC = CountriesTableViewController(presenter: presenter)
		presenter.tableVC = tableVC
		router.vc = tableVC

		return tableVC
	}

	func createDetailCountryModule(country: Country) -> DetailCountryViewController {

		let presenter = DetailCountryPresenter(country: country)
		let vc = DetailCountryViewController(presenter: presenter)

		return vc
	}
}
