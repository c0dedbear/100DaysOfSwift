//
//  TableViewController.swift
//  WordScramble
//
//  Created by Mikhail Medvedev on 21.10.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    var allWords = [String]()
	var usedWords = [String]() {
		didSet {
			saveCurrentState(title, usedWords: usedWords)
		}
	}
    
    enum WordError {
        case notReal, notPossible, theSame, notOriginal
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWords()
        startGame()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promtTheAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reloadGame))
    }
    
    func loadWords() {
        if let fileUrl = Bundle.main.url(forResource: "start", withExtension: "txt") {
            guard let words = try? String(contentsOf: fileUrl) else {
                allWords = ["silkworm"]
                return
            }
            allWords = words.components(separatedBy: "\n")
        }
    }

	private func saveCurrentState(_ word: String?, usedWords: [String]) {
		guard let word = word else { return }
		let defaults = UserDefaults.standard
		defaults.set(word, forKey: "currentWord")
		defaults.set(usedWords, forKey: "usedWords")
	}

    
	func startGame() {
		let defaults = UserDefaults.standard
		if let word = defaults.string(forKey: "currentWord") {
			title = word
			if let words = defaults.stringArray(forKey: "usedWords") {
				usedWords = words
			}
			tableView.reloadData()
		}
		else {
			reloadGame()
		}
	}

	@objc private func reloadGame() {
		let currentWord = allWords.randomElement()
		title = currentWord
		usedWords.removeAll(keepingCapacity: true)
		tableView.reloadData()
	}

    @objc func promtTheAnswer() {
        let ac = UIAlertController(title: "Enter the answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] _ in
            guard let answer = ac?.textFields?.first?.text else { return }
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) {
        let loweredAnswer = answer.lowercased()
        
        if !isSame(word: loweredAnswer) {
            if isPossible(word: loweredAnswer) {
                if isOriginal(word: loweredAnswer) {
                    if isReal(word: loweredAnswer) {
                        let indexPath = IndexPath(row: 0, section: 0)
                        usedWords.insert(answer, at: 0)
                        tableView.insertRows(at: [indexPath], with: .automatic)
                        
                        return
                    } else {
                        //not Real
                        showErrorMessage(error: .notReal)
                    }
                } else {
                    //not Original
                    showErrorMessage(error: .notOriginal)
                }
            } else {
                //not Possible
                showErrorMessage(error: .notPossible)
                
            }
        } else {
            //is the same
            showErrorMessage(error: .theSame)
        }
        
        
    }
    
    func showErrorMessage(error: WordError) {
        
        var errorTitle = ""
        var errorMessage = ""
        
        switch error {
        case .notOriginal:
            errorTitle = "Word used already"
            errorMessage = "Be more original!"
        case .notPossible:
            if let title = title?.lowercased() {
                errorTitle = "Word not possible"
                errorMessage = "You can't spell that word from \(title)"
            }
        case .notReal:
            errorTitle = "Word not recognised"
            errorMessage = "You can't just make them up, you know!"
        case .theSame:
            errorTitle = "Try again"
            errorMessage = "The whole same word not allowed"
        }
        
        
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        ac.addAction(action)
        
        present(ac, animated: true)
    }
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false }
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        let wordLow = word.lowercased()
        let wordUp = word.uppercased()
        return !usedWords.contains(wordLow) && !usedWords.contains(wordUp)
    }
    
    func isReal(word: String) -> Bool {
        if word.count < 3 {
            return false
        }
        
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count) //I realize this seems like pointless additional complexity, so let me try to give you a simple rule: when you’re working with UIKit, SpriteKit, or any other Apple framework, use utf16.count for the character count. If it’s just your own code - i.e. looping over characters and processing each one individually – then use count instead.
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func isSame(word: String) -> Bool {
        guard let lowerTitle = title?.lowercased() else { return false }
        if word.lowercased() == lowerTitle {
            return true
        }
        return false
    }
    
    
}

extension TableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
}

