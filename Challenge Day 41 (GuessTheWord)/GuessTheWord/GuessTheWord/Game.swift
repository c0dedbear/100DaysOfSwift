//
//  Game.swift
//  GuessTheWord
//
//  Created by Mikhail Medvedev on 04.11.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import Foundation

struct Game: Codable
{
	var currentWord: String?
	var currentHint: String?
	var guessedLetters = ""
	var words: Words?
	static var alphabet: [Character] {
		let lettersString = "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ"
		var temp = [Character]()
			for char in lettersString {
				temp.append(char)
			}
		return temp
	}
}

struct WordValue: Codable
{
	let definition: String?
}

typealias Words = [String: WordValue]

enum AlphabetLettersCount: Int
{
	case en = 25
	case ru = 33
}
