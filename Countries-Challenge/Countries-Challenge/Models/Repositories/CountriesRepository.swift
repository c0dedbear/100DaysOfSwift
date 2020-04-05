//
//  CountriesRepository.swift
//  Countries-Challenge
//
//  Created by Mikhail Medvedev on 28.11.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

protocol ICountriesRepository: AnyObject
{
	var remoteDataSource: ICountriesDataSource { get }
}

final class CountriesRepository: ICountriesRepository
{
	let remoteDataSource: ICountriesDataSource

	init(remoteDataSource: ICountriesDataSource) {
		self.remoteDataSource = remoteDataSource
	}
}
