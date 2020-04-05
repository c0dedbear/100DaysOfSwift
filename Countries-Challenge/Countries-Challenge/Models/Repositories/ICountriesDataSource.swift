//
//  CountriesDataSourceProtocol.swift
//  Countries-Challenge
//
//  Created by Mikhail Medvedev on 28.11.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import Foundation
import UIKit

protocol ICountriesDataSource: AnyObject
{
	func fetchCountries(completion: @escaping (Result<[Country], Error>) -> Void)
	func fetchImage(from urlString: String, completion: @escaping (Result<UIImage, Error>) -> Void)
}
