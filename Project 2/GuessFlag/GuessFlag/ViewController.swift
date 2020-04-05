//
//  ViewController.swift
//  GuessFlag
//
//  Created by Mikhail Medvedev on 12.10.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var buttons: [UIButton]!
    var scoreLabel = UILabel()
    var questionCountLabel = UILabel()
    
    var countries = ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }

	var bestScore = 0 {
		didSet {
			saveBestScore()
		}
	}

    var currentQuestion = 0 {
        didSet {
            if currentQuestion == 11 {
				let message: String
				if score > bestScore {
					bestScore = score
					message = "You improved you best score! You gained \(bestScore) points"
				} else {
					message = "Your score is \(score)"
				}
                let ac = UIAlertController(
					title: "Questions is over",
					message: message,
					preferredStyle: .alert
				)
                let action = UIAlertAction(title: "New Game", style: .default) { _ in
                    self.currentQuestion = 0
                    self.score = 0
                    self.askQuestion()
                }
                ac.addAction(action)
                present(ac, animated: true)
            } else {
                questionCountLabel.text = "Question \(currentQuestion)\\10"
            }
        }
    }
    
    var correctAnswer = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()
		loadBestScore()
        addBorders(to: buttons)
        addScoreLabel(using: scoreLabel)
        addNumberOfQuestionsLabel(using: questionCountLabel)
        askQuestion()
        print(countries[0],countries[1], countries[2])
    }
    
    func addBorders(to buttons: [UIButton]) {
        for button in buttons {
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.systemGray.cgColor
        }
    }

	private func saveBestScore() {
		if score > bestScore {
			bestScore = score
			let defaults = UserDefaults.standard
			defaults.set(bestScore, forKey: "bestScore")
		}
	}

	private func loadBestScore() {
		let defaults = UserDefaults.standard
		bestScore = defaults.integer(forKey: "bestScore")
	}
    
    func askQuestion() {
        guard countries.count >= buttons.count else { return }
        countries.shuffle()
        for button in buttons {
            let image = UIImage(named: countries[button.tag])
            button.setImage(image, for: .normal)
        }
        
        correctAnswer = Int.random(in: 0...2)
        title = countries[correctAnswer].uppercased()
        currentQuestion += 1
    }
    
    func addScoreLabel(using label: UILabel) {
        label.adjustsFontSizeToFitWidth = true
        label.text = "Score: \(score)"
        let item = UIBarButtonItem(customView: label)
        navigationItem.rightBarButtonItem = item
    }
    
    func addNumberOfQuestionsLabel(using label: UILabel) {
        label.adjustsFontSizeToFitWidth = true
        label.text = "Question \(currentQuestion)\\10"
        let item = UIBarButtonItem(customView: questionCountLabel)
        navigationItem.leftBarButtonItem = item
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        print(sender.tag)
        print(countries[0],countries[1], countries[2])
        print(countries[sender.tag])

		UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: [], animations: {
			sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
		}, completion: { [weak self] finished in
			if finished {
				DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
					if sender.tag == self?.correctAnswer {
						//answer is correct
						self?.score += 1
						self?.askQuestion()
					} else {
						//wrong answer
						let ac = UIAlertController(title: "Wrong Answer", message: "You tapped the flag of \(self?.countries[sender.tag].capitalized)", preferredStyle: .alert)
						let action = UIAlertAction(title: "Continue", style: .default) { _ in
							self?.score -= 1
							self?.askQuestion()
						}

						ac.addAction(action)
						self?.present(ac, animated: true)
					}
					}
				}

		})
		
    }
}

