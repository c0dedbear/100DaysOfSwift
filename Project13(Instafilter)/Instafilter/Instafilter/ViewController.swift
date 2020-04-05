//
//  ViewController.swift
//  Instafilter
//
//  Created by Mikhail Medvedev on 14.11.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.

//swiftlint:disable prohibited_interface_builder
//swiftlint:disable implicitly_unwrapped_optional

import UIKit
import CoreImage

final class ViewController: UIViewController
{
	private var currentImage: UIImage?

	private var context: CIContext!
	private var currentFilter: CIFilter!

	@IBOutlet var imageVIew: UIImageView!

	@IBOutlet var intensitySlider: UISlider!

	@IBOutlet var radiusSlider: UISlider!

	override func viewDidLoad() {
		super.viewDidLoad()

		imageVIew.alpha = 0

		context = CIContext()
		currentFilter = CIFilter(name: "CISepiaTone")

		title = "Instafilter"
		navigationItem.leftBarButtonItem = UIBarButtonItem(
			barButtonSystemItem: .add,
			target: self,
			action: #selector(importImage)
		)
	}

	@IBAction func changeFilterTapped(_ sender: UIButton) {
		let filters = [
			"CIBumpDistortion", "CIGaussianBlur", "CIPixellate",
			"CISepiaTone", "CITwirlDistortion", "CIUnsharpMask",
			"CIVignette",
		]

		let ac = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .actionSheet)
		filters.forEach {
			ac.addAction(UIAlertAction(title: $0, style: .default, handler: { [weak self] action in
				self?.setFilter(action: action, with: sender)
			}))
		}

		ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))

		if let popoverVC = ac.popoverPresentationController {
			popoverVC.sourceView = sender
			popoverVC.sourceRect = sender.bounds
		}

		present(ac, animated: true)
	}

	@IBAction func saveButtonTapped(_ sender: UIButton) {
		guard let currentImage = imageVIew.image else {

			let ac = UIAlertController(title: "Error",
									   message: "There no image to save. Choose an image from your library, then repeat",
									   preferredStyle: .alert)
			ac.addAction(UIAlertAction(title: "OK", style: .default))
			present(ac, animated: true)
			return
		}

		UIImageWriteToSavedPhotosAlbum(currentImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
	}

	@IBAction func intensityChanged(_ sender: UISlider) {
		applyImageProcessing()
	}

	@IBAction func radiusChanged(_ sender: UISlider) {
		applyImageProcessing()
	}

	@objc private func importImage() {
		let picker = UIImagePickerController()
		picker.allowsEditing = true
		picker.delegate = self
		present(picker, animated: true)
	}

	func setFilter(action: UIAlertAction, with button: UIButton) {
		guard let actionTitle = action.title else { return }
		button.setTitle(actionTitle, for: .normal)

		guard let currentImage = currentImage else { return }

		currentFilter = CIFilter(name: actionTitle)

		let beginImage = CIImage(image: currentImage)
		currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
		applyImageProcessing()
	}

	func applyImageProcessing() {
		guard let currentImage = currentImage else { return }

		let inputKeys = currentFilter.inputKeys

		if inputKeys.contains(kCIInputIntensityKey) {
			currentFilter.setValue(intensitySlider.value, forKey: kCIInputIntensityKey)
		}
		if inputKeys.contains(kCIInputRadiusKey) {
			currentFilter.setValue(radiusSlider.value * 200, forKey: kCIInputRadiusKey)
		}
		if inputKeys.contains(kCIInputScaleKey) {
			currentFilter.setValue(intensitySlider.value * 10, forKey: kCIInputScaleKey)
		}
		if inputKeys.contains(kCIInputCenterKey) {
			currentFilter.setValue(CIVector(
				x: currentImage.size.width / 2, y: currentImage.size.height / 2),
				forKey: kCIInputCenterKey
		)
		}

		guard let outputImage = currentFilter.outputImage else { return }

		if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
			let processedImage = UIImage(cgImage: cgImage)
			imageVIew.image = processedImage
		}
	}

	@objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
		if let error = error {
			let ac = UIAlertController(title: "Save error",
									   message: error.localizedDescription,
									   preferredStyle: .alert)
			ac.addAction(UIAlertAction(title: "OK", style: .default))
			present(ac, animated: true)
		}
		else {
			let ac = UIAlertController(title: "Saved!",
									   message: "Your altered image has been saved to your photos.",
									   preferredStyle: .alert)
			ac.addAction(UIAlertAction(title: "OK", style: .default))
			present(ac, animated: true)
		}
	}
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
	func imagePickerController(
		_ picker: UIImagePickerController,
		didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

		guard let image = info[.editedImage] as? UIImage else { return }

		dismiss(animated: true)

		currentImage = image

		UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
			self.imageVIew.alpha = 1.0
		})

		let beginCIImage = CIImage(image: image)
		currentFilter.setValue(beginCIImage, forKey: kCIInputImageKey)
		applyImageProcessing()
	}
}
