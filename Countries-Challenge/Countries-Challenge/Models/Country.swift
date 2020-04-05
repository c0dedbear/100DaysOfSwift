//
//  Country.swift
//  Countries-Challenge
//
//  Created by Mikhail Medvedev on 28.11.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import Foundation

struct Country
{
	var name: String
	var capital: String
	var region: Region
	var population: Int
	var flag: String
}

extension Country: Codable {}

enum Region: String, Codable
{
	case africa = "Africa"
	case americas = "Americas"
	case asia = "Asia"
	case empty = ""
	case europe = "Europe"
	case oceania = "Oceania"
	case polar = "Polar"
}
