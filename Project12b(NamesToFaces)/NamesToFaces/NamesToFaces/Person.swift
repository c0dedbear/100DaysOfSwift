//
//  Person.swift
//  NamesToFaces
//
//  Created by Mikhail Medvedev on 08.11.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit
final class Person: NSObject, Codable
{
	var name: String
	var image: String

	init(name: String, image: String) {
		self.name = name
		self.image = image
	}
}
