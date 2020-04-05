//
//  ActionViewController.swift
//  Extension
//
//  Created by Mikhail Medvedev on 10.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {
	@IBOutlet var textView: UITextView!

	private var pageTitle = ""
	private var pageUrl = ""
	
	fileprivate func addKeyboardNotificationObservers() {
		let notificationCenter = NotificationCenter.default
		notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
		notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
	}

	fileprivate func evaluateExtensionContext() {
		if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
			if let itemProvider = inputItem.attachments?.first {
				itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) { [weak self] (dict, error) in
					//do stuff
					guard let itemDictionary = dict as? NSDictionary else { return }
					guard let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }
					self?.pageTitle = javaScriptValues["title"] as? String ?? ""
					self?.pageUrl = javaScriptValues["URL"] as? String ?? ""

					DispatchQueue.main.async {
						self?.title = self?.pageTitle
					}
				}
			}
		}
	}

	override func viewDidLoad() {
        super.viewDidLoad()

		addKeyboardNotificationObservers()

		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(chooseScript))
		evaluateExtensionContext()
    }

	@objc private func chooseScript() {
		let ac = UIAlertController(title: "Выбери скрипт", message: nil, preferredStyle: .actionSheet)
		let showTitle = UIAlertAction(title: "Поздравить", style: .default) { [weak self ] action in
			self?.textView.text = "alert(\"Вова с днем рождения 🎉, это написано на JavaScript внутри iOS 😁\");"
			self?.done()
		}
		ac.addAction(showTitle)
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		ac.addAction(cancelAction)
		present(ac, animated: true)
	}

    @IBAction func done() {
	   let item = NSExtensionItem()
	   let argument: NSDictionary = ["customJavaScript": textView.text ?? ""]
	   let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
	   let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
	   item.attachments = [customJavaScript]

	   extensionContext?.completeRequest(returningItems: [item])
    }

	@objc func adjustForKeyboard(notification: Notification) {
		guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

		let keyboardEndFrameValue = keyboardValue.cgRectValue
		let keyboardViewEndFrame = view.convert(keyboardEndFrameValue, from: view.window)

		if notification.name == UIResponder.keyboardWillHideNotification {
			textView.contentInset = .zero
		}
		else {
			textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
		}

		textView.scrollIndicatorInsets = textView.contentInset

		let selectedRange = textView.selectedRange
		textView.scrollRangeToVisible(selectedRange)
	}
}
