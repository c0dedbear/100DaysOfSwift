//
//  ViewController.swift
//  Project27-CoreGraphics
//
//  Created by Mikhail Medvedev on 06.01.2020.
//  Copyright © 2020 Mikhail Medvedev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet var imageView: UIImageView!

	var currentDrawType = 0

	override func viewDidLoad() {
		super.viewDidLoad()
		drawRectangle()
	}

	func drawRectangle() {
		let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))

		let image = renderer.image { context in
			//drawing code must be here
			let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512).insetBy(dx: 10, dy: 10)

			context.cgContext.setFillColor(UIColor.red.cgColor)
			context.cgContext.setStrokeColor(UIColor.black.cgColor)
			context.cgContext.setLineWidth(10)

			context.cgContext.addRect(rectangle)
			context.cgContext.drawPath(using: .fillStroke)

		}

		imageView.image = image
	}

	func drawCircle() {
		let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))

		let image = renderer.image { context in
			//drawing code must be here
			let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512).insetBy(dx: 15, dy: 15)

			context.cgContext.setFillColor(UIColor.red.cgColor)
			context.cgContext.setStrokeColor(UIColor.black.cgColor)
			context.cgContext.setLineWidth(10)

			context.cgContext.addEllipse(in: rectangle)
			context.cgContext.drawPath(using: .fillStroke)

		}

		imageView.image = image
	}

	func drawChessboard() {
		let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))

		let image = renderer.image { context in
			//drawing code must be here
			context.cgContext.setFillColor(UIColor.black.cgColor)

			for row in 0 ..< 8 {
				for col in 0 ..< 8 {
					if (row + col).isMultiple(of: 2) {
						context.cgContext.fill(CGRect(x: col * 64, y: row * 64, width: 64, height: 64))
					}
				}
			}
		}

		imageView.image = image
	}

	func drawRotatedSquares() {
		let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))

		let image = renderer.image { context in
			context.cgContext.translateBy(x: 256, y: 256)

			let rotations = 16
			let amount = Double.pi / Double(rotations)

			for _ in 0 ..< rotations {
				context.cgContext.rotate(by: CGFloat(amount))
				context.cgContext.addRect(CGRect(x: -128, y: -128, width: 256, height: 256))
			}

			context.cgContext.setStrokeColor(UIColor.black.cgColor)
			context.cgContext.strokePath()
		}

		imageView.image = image
	}

	func drawLines() {
		let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))

		let image = renderer.image { contex in
			contex.cgContext.translateBy(x: 256, y: 256)

			var first = true
			var length: CGFloat = 256

			for _ in 0 ..< 256 {
				contex.cgContext.rotate(by: .pi / 2)

				if first {
					contex.cgContext.move(to: CGPoint(x: length, y: 50))
					first = false
				} else {
					contex.cgContext.addLine(to: CGPoint(x: length, y: 50))
				}

				length *= 0.99
			}

			contex.cgContext.setStrokeColor(UIColor.black.cgColor)
			contex.cgContext.strokePath()
		}

		imageView.image = image
	}

	func drawImageAndText() {
		let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))

		let image = renderer.image { contex in
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.alignment = .left

			let attrs: [NSAttributedString.Key: Any] = [
				.font: UIFont.systemFont(ofSize: 38),
				.paragraphStyle: paragraphStyle,
			]

			let string = "The best-laid schemes o'\nmice an' men gang aft agley"
			let attributedString = NSAttributedString(string: string, attributes: attrs)

			attributedString.draw(with: CGRect(x: 32, y: 32, width: 448, height: 448), options: .usesLineFragmentOrigin, context: nil)

			let mouseImage = UIImage(named: "mouse")
			mouseImage?.draw(at: CGPoint(x: 300, y: 150))
		}

		imageView.image = image
	}

	@IBAction func redrawTapped(_ sender: UIButton) {
		currentDrawType += 1

		if currentDrawType > 5 {
			currentDrawType = 0
		}

		switch currentDrawType {
		case 0: drawRectangle()
		case 1: drawCircle()
		case 2: drawChessboard()
		case 3: drawRotatedSquares()
		case 4: drawLines()
		case 5: drawImageAndText()
		default:
			break
		}
	}



}

