//
//  ViewController.swift
//  7LittleWords
//
//  Created by Mikhail Medvedev on 31.10.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

final class ViewController: UIViewController
{
	// MARK: - Properties
	var cluesLabel = UILabel()
	var answersLabel = UILabel()
	var currentAnswerTextField = UITextField()
	var levelLabel = UILabel()
	var scoreLabel = UILabel()
	var letterButtons = [UIButton]()
	var activatedButtons = [UIButton]()

	let submitButton = UIButton(type: .system)
	let clearButton = UIButton(type: .system)
	let letterButtonsView = UIView()

	var solutions = [String]()
	var score = 0 {
		didSet {
			scoreLabel.text = "Score: \(score)"
		}
	}
	var level = 1 {
		didSet {
			levelLabel.text = "Level \(level)"
		}
	}

	// MARK: - VC Lifecycle
	override func loadView() {
		setupMainView()
		setupLevelLabel()
		setupScoreLabel()
		setupCluesLabel()
		setupAnswersLabel()
		setupCurrentAnswerTextField()
		setupSubmitButton()
		setupClearButton()
		setupLettersButtonsView()
		activateConstraints()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		performSelector(inBackground: #selector(loadLevel), with: nil)
	}
	// MARK: Configure View Methods
	private func setupMainView() {
		view = UIView()
		view.backgroundColor = .white
	}

	private func setupScoreLabel() {
		scoreLabel.translatesAutoresizingMaskIntoConstraints = false
		scoreLabel.textAlignment = .right
		scoreLabel.font = .systemFont(ofSize: 20)
		scoreLabel.text = "Score: 0"

		view.addSubview(scoreLabel)
	}

	private func setupLevelLabel() {
		levelLabel.translatesAutoresizingMaskIntoConstraints = false
		levelLabel.font = .systemFont(ofSize: 20)
		levelLabel.text = "Level: 1"

		view.addSubview(levelLabel)
	}

	private func setupCluesLabel() {
		cluesLabel.translatesAutoresizingMaskIntoConstraints = false
		cluesLabel.font = .systemFont(ofSize: 24)
		cluesLabel.numberOfLines = 0
		cluesLabel.text = "CLUES"

		view.addSubview(cluesLabel)
	}

	private func setupAnswersLabel() {
		answersLabel.translatesAutoresizingMaskIntoConstraints = false
		answersLabel.font = .systemFont(ofSize: 24)
		answersLabel.numberOfLines = 0
		answersLabel.text = "ANSWERS"
		answersLabel.textAlignment = .right

		view.addSubview(answersLabel)
	}

	private func setupCurrentAnswerTextField() {
		currentAnswerTextField.translatesAutoresizingMaskIntoConstraints = false
		currentAnswerTextField.font = .systemFont(ofSize: 44)
		currentAnswerTextField.placeholder = "Tap letter to guess"
		currentAnswerTextField.isUserInteractionEnabled = false
		currentAnswerTextField.textAlignment = .center

		view.addSubview(currentAnswerTextField)
	}

	private func setupSubmitButton() {
		submitButton.translatesAutoresizingMaskIntoConstraints = false
		submitButton.setTitle("SUBMIT", for: .normal)
		submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)

		view.addSubview(submitButton)
	}

	private func setupClearButton() {
		clearButton.translatesAutoresizingMaskIntoConstraints = false
		clearButton.setTitle("CLEAR", for: .normal)
		clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)

		view.addSubview(clearButton)
	}

	private func setupLettersButtonsView() {
		letterButtonsView.translatesAutoresizingMaskIntoConstraints = false
		letterButtonsView.layer.borderColor = UIColor.gray.cgColor
		letterButtonsView.layer.borderWidth = 0.5

		addLetterButtons(to: letterButtonsView)
		view.addSubview(letterButtonsView)
	}

	private func addLetterButtons(to view: UIView) {
		let width = 150
		let height = 80
		letterButtons = [UIButton]()
		for row in 0..<4 {
			for column in 0..<5 {
				let button = UIButton(type: .system)
				button.titleLabel?.font = .systemFont(ofSize: 36)
				button.setTitle("WWW", for: .normal)
				button.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
				let frame = CGRect(x: column * width, y: row * height, width: width, height: height)
				button.frame = frame

				view.addSubview(button)
				letterButtons.append(button)
			}
		}
	}

	private func activateConstraints() {

		cluesLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
		answersLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)

		NSLayoutConstraint.activate([
			scoreLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
			scoreLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),

			levelLabel.topAnchor.constraint(equalTo: scoreLabel.topAnchor),
			levelLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),

			cluesLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
			cluesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100),
			cluesLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6, constant: -100),

			answersLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
			answersLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -100),
			answersLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4, constant: -100),
			answersLabel.heightAnchor.constraint(equalTo: cluesLabel.heightAnchor),

			currentAnswerTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			currentAnswerTextField.topAnchor.constraint(equalTo: answersLabel.bottomAnchor, constant: 20),
			currentAnswerTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),

			submitButton.topAnchor.constraint(equalTo: currentAnswerTextField.bottomAnchor),
			submitButton.centerXAnchor.constraint(equalTo: currentAnswerTextField.centerXAnchor, constant: -100),
			submitButton.heightAnchor.constraint(equalToConstant: 44),

			clearButton.topAnchor.constraint(equalTo: currentAnswerTextField.bottomAnchor),
			clearButton.centerXAnchor.constraint(equalTo: currentAnswerTextField.centerXAnchor, constant: 100),
			clearButton.heightAnchor.constraint(equalTo: submitButton.heightAnchor),

			letterButtonsView.widthAnchor.constraint(equalToConstant: 750),
			letterButtonsView.heightAnchor.constraint(equalToConstant: 320),
			letterButtonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			letterButtonsView.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 20),
			letterButtonsView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20),
		])
	}
	// MARK: - Game LOGIC Methods
	@objc private func loadLevel() {
		var clueString = ""
		var solutionString = ""
		var lettersBits = [String]()

		guard let levelURL = Bundle.main.url(
			forResource: "level\(level)",
			withExtension: "txt"
			) else { fatalError("Failed to find level file") }
		guard let levelContent = try? String(contentsOf: levelURL) else { fatalError("Fail to read level's content ") }
		var lines = levelContent.components(separatedBy: "\n")
		lines.shuffle()

		for (index, line) in lines.enumerated() {
			let parts = line.components(separatedBy: ": ")
			let answer = parts[0]
			let clue = parts[1]

			clueString += "\(index + 1). \(clue)\n"

			let solutionWord = answer.replacingOccurrences(of: "|", with: "")
			solutionString += "\(solutionWord.count) letters\n"
			solutions.append(solutionWord)

			let bits = answer.components(separatedBy: "|")
			lettersBits += bits
		}

		DispatchQueue.main.async {
			self.cluesLabel.text = clueString.trimmingCharacters(in: .whitespacesAndNewlines)
			self.answersLabel.text = solutionString.trimmingCharacters(in: .whitespacesAndNewlines)

			lettersBits.shuffle()

			if lettersBits.count == self.letterButtons.count {
				for index in 0..<self.letterButtons.count {
					self.letterButtons[index].setTitle(lettersBits[index], for: .normal)
				}
			}
		}
	}

	private func levelUp(action: UIAlertAction) {
		level += 1
		solutions.removeAll(keepingCapacity: true)

		performSelector(inBackground: #selector(loadLevel), with: nil)

		letterButtons.forEach { $0.isHidden = false }
	}

	private func resetCurrentState() {
		currentAnswerTextField.text = ""
		activatedButtons.forEach { $0.isHidden = false }
		activatedButtons.removeAll()
	}

	private func wrongAnswer(action: UIAlertAction) {
		resetCurrentState()
		score -= 1
	}

	private func isAllButtonsHidden() -> Bool {
		for button in letterButtons where button.isHidden == false {
			return false
		}
		return true
	}

	// MARK: - @Objc Methods
	@objc func submitTapped(_ sender: UIButton) {
		guard let answerText = currentAnswerTextField.text else { return }
		if let solutionIndex = solutions.firstIndex(of: answerText) {
			activatedButtons.removeAll()

			var splitAnswers = answersLabel.text?.components(separatedBy: "\n")
			splitAnswers?[solutionIndex] = answerText
			answersLabel.text = splitAnswers?.joined(separator: "\n")

			currentAnswerTextField.text = ""
			score += 1

			//next level
			if isAllButtonsHidden() {
				let ac = UIAlertController(
					title: "Well done!",
					message: "Are you ready for the next level?",
					preferredStyle: .alert
				)
				ac.addAction(UIAlertAction(title: "Let's go!", style: .default, handler: levelUp))
				present(ac, animated: true)
			}
		}
		else {
			//wrong guess
			let ac = UIAlertController(
				title: "Wrong guess",
				message: "Please, try again.",
				preferredStyle: .alert
			)
			ac.addAction(UIAlertAction(title: "OK", style: .default, handler: wrongAnswer))
			present(ac, animated: true)
		}
	}

	@objc func clearTapped(_ sender: UIButton) {
		resetCurrentState()
	}

	@objc func letterTapped(_ sender: UIButton) {
		guard let buttonTitle = sender.titleLabel?.text else { return }
		currentAnswerTextField.text = currentAnswerTextField.text?.appending(buttonTitle)
		activatedButtons.append(sender)
		UIView.animate(withDuration: 0.25, delay: 0, options: [], animations: {
			sender.alpha = 0
		})
		//sender.isHidden = true
	}
}
