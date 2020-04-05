//
//  Person.swift
//  NamesToFaces
//
//  Created by Mikhail Medvedev on 08.11.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit
final class Person: NSObject, NSCoding
{
	var name: String
	var image: String

	func encode(with coder: NSCoder) {
		coder.encode(name, forKey: "name")
		coder.encode(image, forKey: "image")
	}

	init(name: String, image: String) {
		self.name = name
		self.image = image
	}

	required init(coder: NSCoder) {
		name = coder.decodeObject(forKey: "name") as? String ?? ""
		image = coder.decodeObject(forKey: "image") as? String ?? ""
	}
}
