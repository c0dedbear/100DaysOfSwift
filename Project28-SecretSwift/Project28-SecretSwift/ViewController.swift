//
//  ViewController.swift
//  Project28-SecretSwift
//
//  Created by Mikhail Medvedev on 13.02.2020.
//  Copyright © 2020 Mikhail Medvedev. All rights reserved.
//

import LocalAuthentication
import UIKit

class ViewController: UIViewController {

	private var isPasswordSet: Bool {
		KeychainWrapper.standard.hasValue(forKey: "pwd")
	}
	
	@IBOutlet var secretText: UITextView!

	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Nothing to see here"
		addNotificationObservers()
		showSetPasswordButton()
	}

	private func addDoneButton() {
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
	}

	private func showSetPasswordButton() {
		if isPasswordSet {
			navigationItem.leftBarButtonItem = nil
		}
		else {
			addSetPasswordButton()
		}
	}

	private func addSetPasswordButton() {
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Set pwd", style: .plain, target: self, action: #selector(setPasswordTapped))
	}

	private func addNotificationObservers() {
		let notificationCenter = NotificationCenter.default
		notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
		notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
		notificationCenter.addObserver(self, selector: #selector(saveSecretText), name: UIApplication.willResignActiveNotification, object: nil)
	}

	private func authenticateWithBiometrics() {
		let context = LAContext()
		var error: NSError?

		if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
			let reason = "We need to identify you"
			context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, error in
				DispatchQueue.main.async {
					if success {
						self?.unlockText()
					}
					else {
						// face id or touch id is not matched
						let ac = UIAlertController(title: "Authentication failed", message: "You could not be verified; please try again.", preferredStyle: .alert)
						ac.addAction(UIAlertAction(title: "Enter password", style: .default, handler: { [weak self] _ in
							self?.presentAcForEnterPwd()
						}))
						ac.addAction(UIAlertAction(title: "Cancel", style: .default))
						self?.present(ac, animated: true)
					}
				}
			}
		}
		else {
			// no biometry
			let ac = UIAlertController(title: "Biometry unavailable", message: "Your device is not configured for biometric authentication.", preferredStyle: .alert)

			let cancel = UIAlertAction(title: "Cancel", style: .cancel)
			let set = UIAlertAction(title: "Enter with password", style: .default) { [weak self] _ in
				self?.presentAcForEnterPwd()
			}

			ac.addAction(cancel)
			ac.addAction(set)
			present(ac, animated: true)
		}
	}

	private func presentAcForEnterPwd() {

		let ac = UIAlertController(title: "Enter password", message: nil, preferredStyle: .alert)

		if isPasswordSet {
			ac.addTextField { textField in
				textField.isSecureTextEntry = true
			}

			let cancel = UIAlertAction(title: "Cancel", style: .cancel)
			let set = UIAlertAction(title: "Enter", style: .default) { [weak self] _ in
				guard let pwd = ac.textFields?.first?.text else { return }
				guard pwd.isEmpty == false else { return }
				if pwd == KeychainWrapper.standard.string(forKey: "pwd") {
					self?.unlockText()
				} else {
					let ac = UIAlertController(title: "Authentication failed", message: "You could not be verified; please try again.", preferredStyle: .alert)
					ac.addAction(UIAlertAction(title: "OK", style: .default))
					self?.present(ac, animated: true)
				}
			}
			ac.addAction(cancel)
			ac.addAction(set)
			present(ac, animated: true)
		}
		else {
			setPasswordTapped()
		}
	}

	@objc private func saveSecretText() {
		guard secretText.isHidden == false else { return }
		KeychainWrapper.standard.set(secretText.text, forKey: "SecretText")
		secretText.resignFirstResponder()
		secretText.isHidden = true
		title = "Nothing to see here"
		navigationItem.rightBarButtonItem = nil
		showSetPasswordButton()
	}

	private func unlockText() {
		navigationItem.leftBarButtonItem = nil
		title = "Secret stuff!"
		secretText.isHidden = false
		secretText.text = KeychainWrapper.standard.string(forKey: "SecretText") ?? ""
		addDoneButton()
	}

	@objc private func adjustForKeyboard(notification: Notification) {
		guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

		let keyboardScreenEnd = keyboardValue.cgRectValue
		let keyboardViewEndFrame = view.convert(keyboardScreenEnd, from: view.window)

		if notification.name == UIResponder.keyboardWillHideNotification {
			secretText.contentInset = .zero
		} else {
			secretText.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
		}

		secretText.scrollIndicatorInsets = secretText.contentInset

		let selectedRange = secretText.selectedRange
		secretText.scrollRangeToVisible(selectedRange)
	}

	@objc private func doneButtonTapped() {
		saveSecretText()
	}

	@objc private func setPasswordTapped() {
		let ac = UIAlertController(title: "Set password", message: "Use this password if biometric authentication will failed", preferredStyle: .alert)
		ac.addTextField { textField in
			textField.isSecureTextEntry = true
		}

		let cancel = UIAlertAction(title: "Cancel", style: .cancel)
		let set = UIAlertAction(title: "Set password", style: .default) { [weak self] _ in
			guard let pwd = ac.textFields?.first?.text else { return }
			guard pwd.isEmpty == false else { return }
			KeychainWrapper.standard.set(pwd, forKey: "pwd")
			self?.showSetPasswordButton()
		}

		ac.addAction(cancel)
		ac.addAction(set)

		present(ac, animated: true)
	}

	@IBAction func authenticateTapped(_ sender: UIButton) {
		//unlockText()
		authenticateWithBiometrics()
	}
}

