//
//  ViewController.swift
//  GuessTheWord
//
//  Created by Mikhail Medvedev on 04.11.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

final class ViewController: UIViewController
{
// MARK: Properties
	var game: Game?

	var hintTextView = UITextView()
	var wordLabel = UILabel()
	var letterButtonsView = UIView()
	var lettersButtons = [UIButton]()

// MARK: Lifecycle Methods
	override func loadView() {
		setupMainView()
		setupHintTextView()
		setupWordTextField()
		setupLettersButtonsView()
		activateCosntraints()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		loadLevel()
		print(lettersButtons.count)
	}

// MARK: Setup UI Methods
	private func setupMainView() {
		view = UIView()
		view.backgroundColor = .white
	}

	private func setupHintTextView() {
		hintTextView.translatesAutoresizingMaskIntoConstraints = false
		hintTextView.font = .systemFont(ofSize: 20)
		hintTextView.text = "Hint: ***"
		hintTextView.textAlignment = .center
		hintTextView.isEditable = false
		hintTextView.scrollRangeToVisible(NSRange())
		view.addSubview(hintTextView)
	}

	private func setupWordTextField() {
		wordLabel.translatesAutoresizingMaskIntoConstraints = false
		wordLabel.font = .systemFont(ofSize: 40, weight: .heavy)
		wordLabel.text = "***"
		wordLabel.textAlignment = .center
		wordLabel.numberOfLines = 1
		wordLabel.adjustsFontSizeToFitWidth = true
		view.addSubview(wordLabel)
	}

	private func setupLettersButtonsView() {
		letterButtonsView.translatesAutoresizingMaskIntoConstraints = false
		setupLettersButtons(to: letterButtonsView)
		view.addSubview(letterButtonsView)
	}

// MARK: Update UI Methods
	private func loadLevel() {
		if let words = game?.words {
			//next level
			let randomElement = words.randomElement()
			game?.currentWord = randomElement?.key
			game?.currentHint = randomElement?.value.definition
			wordLabel.text = String(repeating: "?",
										 count: self.game?.currentWord?.count ?? 1)
			hintTextView.text = self.game?.currentHint
		}
		else {
			//new game
			parseJson()
		}
		//implement buttons to alphabet letters
		for index in 0..<lettersButtons.count {
			lettersButtons[index].setTitle("\(Game.alphabet[index])", for: .normal)
		}
	}
// MARK: PARSING JSON
	private func parseJson() {
		DispatchQueue.global(qos: .default).async {
			guard let jsonUrl = Bundle.main.url(
				forResource: "russian_nouns_with_definition",
				withExtension: "json"
				)
				else { fatalError("Can't find json file") }
			guard let data = try? Data(contentsOf: jsonUrl) else { fatalError("Can't load data") }

			let decoder = JSONDecoder()
			if let words = try? decoder.decode(Words.self, from: data) {
				let randomWord = words.randomElement()
				self.game = Game(currentWord: randomWord?.key, currentHint: randomWord?.value.definition, words: words)
				DispatchQueue.main.async {
					self.wordLabel.text = String(repeating: "?",
												 count: self.game?.currentWord?.count ?? 1)
					self.hintTextView.text = self.game?.currentHint
				}
			}
			else {
				DispatchQueue.main.async {
					let ac = UIAlertController(title: "Error", message: "Failed to load words", preferredStyle: .alert)
					let okAction = UIAlertAction(title: "Try again", style: .default) { _ in
						self.parseJson()
					}
					ac.addAction(okAction)
					self.present(ac, animated: true)
				}
			}
		}
	}
// MARK: - FIX ME
	//сделать чтобы кнопки отбражались в зависимости от ширины\высоты вьюхи
	private func setupLettersButtons(to view: UIView) {
		let size = 40
		let rowCount = 10
		let columsCount =
			AlphabetLettersCount.ru.rawValue % rowCount == 0 ?
			(AlphabetLettersCount.ru.rawValue / rowCount) : (AlphabetLettersCount.ru.rawValue / rowCount) + 1

		createButtons: for row in 0..<rowCount {
			for col in 0..<columsCount {
				if AlphabetLettersCount.ru.rawValue != lettersButtons.count {
				let button = UIButton(type: .system)
				let frame = CGRect(x: row * size, y: col * size, width: size, height: size)
				button.frame = frame
				button.titleLabel?.font = .systemFont(ofSize: 30)
				button.setTitle("?", for: .normal)
				button.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
				view.addSubview(button)
				lettersButtons.append(button)
				}
				else {
					break createButtons
				}
			}
		}
	}

	@objc private func letterTapped(_ sender: UIButton) {
		guard
			let currentWord = game?.currentWord?.uppercased(),
			let guessedLetters = game?.guessedLetters
			else { return }
		let guessedLetter = Character(sender.titleLabel?.text ?? "+")
		if currentWord.contains(guessedLetter)
			&& guessedLetters.contains(guessedLetter) == false {
			var tempArray = Array(wordLabel.text ?? "+")
			for (index, letter) in currentWord.enumerated() where letter == guessedLetter  {
				tempArray[index] = guessedLetter
			}
			wordLabel.text = String(tempArray)
			game?.guessedLetters.append(guessedLetter)
		}

		if currentWord == wordLabel.text {
			let ac = UIAlertController(title: "You win!", message: "Вы отгадали слово!", preferredStyle: .alert)
			let okAction = UIAlertAction(title: "Другое слово", style: .default) { _ in
				self.loadLevel()
			}
			ac.addAction(okAction)
			self.present(ac, animated: true)
		}
	}

	private func activateCosntraints() {
		NSLayoutConstraint.activate([
			hintTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			hintTextView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20),
			hintTextView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9, constant: 0),

			wordLabel.topAnchor.constraint(equalTo: hintTextView.bottomAnchor, constant: 24 ),
			wordLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			wordLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2, constant: 0),
			wordLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9, constant: 0),

			letterButtonsView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9, constant: 0),
			letterButtonsView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.33, constant: 0),
			letterButtonsView.topAnchor.constraint(equalTo: wordLabel.bottomAnchor, constant: 20),
			letterButtonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			letterButtonsView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20),
		])
	}
}
