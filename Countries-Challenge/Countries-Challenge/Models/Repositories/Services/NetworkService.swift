//
//  NetworkService.swift
//  Countries-Challenge
//
//  Created by Mikhail Medvedev on 28.11.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

enum URLError: Error
{
	case wrongURL
	case noImage
}

final class NetworkService
{
	private let session = URLSession(configuration: .default)
	private var dataTask: URLSessionDataTask?
}

extension NetworkService: ICountriesDataSource
{
	func fetchCountries(completion: @escaping (Result<[Country], Error>) -> Void) {
		guard let url = URL(string: "https://restcountries.eu/rest/v2/all") else {
			completion(.failure(URLError.wrongURL))
			return
		}

		dataTask?.cancel()

		dataTask = session.dataTask(with: url) { data, _, error in

			if let data = data {
				let jSONDecoder = JSONDecoder()
				do {
					let countries = try jSONDecoder.decode([Country].self, from: data)
					completion(.success(countries))
				}
				catch {
					completion(.failure(error))
				}
			}
			else {
				guard let error = error else { return }
				completion(.failure(error))
			}
		}

		dataTask?.resume()
	}

	func fetchImage(from urlString: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
		guard let url = URL(string: urlString) else {
			completion(.failure(URLError.wrongURL))
			return
		}

		dataTask?.cancel()

		dataTask = session.dataTask(with: url) { data, response, error in
			if let data = data,
				let response = response as? HTTPURLResponse,
				response.statusCode == 200 {

				if let image = UIImage(data: data) {
					completion(.success(image))
				}
				else {
					guard let error = error else { return }
					completion(.failure(error))
				}
			}
			else {
				guard let error = error else { return }
				completion(.failure(error))
			}
		}

		dataTask?.resume()
	}
}
