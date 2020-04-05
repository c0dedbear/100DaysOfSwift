//
//  ViewController.swift
//  MemeGen-challenge-90
//
//  Created by Mikhail Medvedev on 12.02.2020.
//  Copyright © 2020 Mikhail Medvedev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet var topText: UITextView!
	@IBOutlet var bottomText: UITextView!
	@IBOutlet var imageView: UIImageView!
	@IBOutlet var scrollView: UIScrollView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		addTextDelegates()
		addTapRecognizer(to: imageView)
		addToolBarForTextView()
		addKeyboardNotification()
		addExportButton()
	}

	private func addTextDelegates() {
		topText.textContainer.lineBreakMode = .byWordWrapping
		bottomText.textContainer.lineBreakMode = .byWordWrapping
		topText.textContainer.maximumNumberOfLines = 2
		bottomText.textContainer.maximumNumberOfLines = 2
		topText.delegate = self
		bottomText.delegate = self
	}

	private func addExportButton() {
		let exportButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(exportTapped))
		navigationItem.rightBarButtonItem = exportButton
		navigationItem.rightBarButtonItem?.isEnabled = false
	}

	private func addTapRecognizer(to view: UIView) {
		let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
		tapRecognizer.numberOfTapsRequired = 1
		view.addGestureRecognizer(tapRecognizer)
	}

	private func addKeyboardNotification() {
		let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
	}

	@objc private func exportTapped() {
		drawImageAndText()
	}

	@objc private func imageTapped() {
		pickImage()
	}

	@objc private func adjustForKeyboard(notification: Notification) {
		let userInfo = notification.userInfo!

		let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
		let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

		if notification.name == UIResponder.keyboardWillHideNotification {
			scrollView.contentInset = UIEdgeInsets.zero
		} else {
			scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
		}

		scrollView.scrollIndicatorInsets = scrollView.contentInset
	}

	private func pickImage() {
		let picker = UIImagePickerController()
		picker.delegate = self
		picker.allowsEditing = true
		present(picker, animated: true)
	}

	private func imageSizeAspectFit(imgview: UIImageView) -> CGSize {
        var newwidth: CGFloat
        var newheight: CGFloat
        let image = imgview.image!

        if image.size.height >= image.size.width {
            newheight = imgview.frame.size.height;
            newwidth = (image.size.width / image.size.height) * newheight
            if newwidth > imgview.frame.size.width {
                let diff: CGFloat = imgview.frame.size.width - newwidth
                newheight = newheight + diff / newheight * newheight
                newwidth = imgview.frame.size.width
            }
        }
        else {
            newwidth = imgview.frame.size.width
            newheight = (image.size.height / image.size.width) * newwidth
            if newheight > imgview.frame.size.height {
                let diff: CGFloat = imgview.frame.size.height - newheight
                newwidth = newwidth + diff / newwidth * newwidth
                newheight = imgview.frame.size.height
            }
        }

        //adapt UIImageView size to image size
		return CGSize(width: newwidth, height: newheight)
    }

	private func drawImageAndText() {

		let renderer = UIGraphicsImageRenderer(size: UIScreen.main.bounds.size)

		let image = renderer.image { contex in

			let currentImage = imageView.image
			currentImage?.draw(in: imageView.frame)

			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.alignment = .center

			let attrs: [NSAttributedString.Key: Any] = [
				.font: UIFont.systemFont(ofSize: 40, weight: .bold),
				.paragraphStyle: paragraphStyle,
				.foregroundColor: UIColor.black,
			]

			let topString = NSAttributedString(string: topText.text, attributes: attrs)
			topString.draw(with: topText.frame, options: .usesLineFragmentOrigin, context: nil)

			let bottomString = NSAttributedString(string: bottomText.text, attributes: attrs)
			bottomString.draw(with: bottomText.frame, options: .usesLineFragmentOrigin, context: nil)
		}

		if let imageData = image.jpegData(compressionQuality: 0.8) {
			let ac = UIActivityViewController(activityItems: [imageData], applicationActivities: nil)
			present(ac, animated: true)
		}
	}
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		if let image = info[.editedImage] as? UIImage {
			imageView.image = image
			imageView.isUserInteractionEnabled = true
			navigationItem.rightBarButtonItem?.isEnabled = true
			picker.dismiss(animated: true)
		}
	}
}

extension ViewController {
	private func addToolBarForTextView() {
		let textViewToolbar: UIToolbar = UIToolbar()
		textViewToolbar.barStyle = .default
		textViewToolbar.items = [
			UIBarButtonItem(title: "Cancel", style: .done,
							target: self, action: #selector(cancelInput)),
			UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
							target: self, action: nil),
			UIBarButtonItem(title: "Done", style: .done,
							target: self, action: #selector(doneInput))
		]
		textViewToolbar.sizeToFit()
		topText.inputAccessoryView = textViewToolbar
		bottomText.inputAccessoryView = textViewToolbar
	}

	@objc private func cancelInput() {
		if topText.text.isEmpty {
			topText.text = "TOP TEXT"
		}

		if bottomText.text.isEmpty {
			bottomText.text = "BOTTOM TEXT"
		}

		view.endEditing(true)
		imageView.isUserInteractionEnabled = true
	}

	@objc private func doneInput() {
		view.endEditing(true)
		imageView.isUserInteractionEnabled = true
	}

	
}

extension ViewController: UITextViewDelegate {

	func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
		imageView.isUserInteractionEnabled = false
		if textView.text.isEmpty ||
			textView.text == "TOP TEXT" ||
			textView.text == "BOTTOM TEXT" {
			textView.text = ""
		}
		return true
	}

//	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
				//exclude spaces and new lines
//		var newText = textView.text!
//		newText.removeAll { (character) -> Bool in
//			return character == " " || character == "\n"
//		}
//
//		return (newText.count + text.count) <= 40
//	}
}
