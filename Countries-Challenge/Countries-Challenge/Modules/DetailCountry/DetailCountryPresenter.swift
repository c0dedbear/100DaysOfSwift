//
//  DetailCountryPresenter.swift
//  Countries-Challenge
//
//  Created by Mikhail Medvedev on 28.11.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import Foundation

protocol IDetailPresentable
{
	func getCountry() -> Country
}

final class DetailCountryPresenter
{
	private var country: Country

	init(country: Country) {
		self.country = country
	}

	deinit {
		print("DetailContactPresenter", #line, #function, Date())
	}
}

extension DetailCountryPresenter: IDetailPresentable
{
	func getCountry() -> Country { country }
}
