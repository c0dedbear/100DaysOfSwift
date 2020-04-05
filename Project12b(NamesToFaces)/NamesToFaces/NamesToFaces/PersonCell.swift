//
//  PersonCell.swift
//  NamesToFaces
//
//  Created by Mikhail Medvedev on 08.11.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//
// swiftlint:disable prohibited_interface_builder
import UIKit

final class PersonCell: UICollectionViewCell
{
	static let identifier = "Person"
	@IBOutlet var imageView: UIImageView!
	@IBOutlet var nameLabel: UILabel!
}
