//
//  Petition.swift
//  WhiteHousePetitions
//
//  Created by Mikhail Medvedev on 27.10.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import Foundation

struct Petition: Codable {
    var title: String
    var body: String
    var signatureCount: Int
}

struct Petitions: Codable {
    var results: [Petition]
}
