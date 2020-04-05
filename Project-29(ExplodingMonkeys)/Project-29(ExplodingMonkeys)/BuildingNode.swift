//
//  BuildingNode.swift
//  Project-29(ExplodingMonkeys)
//
//  Created by Mikhail Medvedev on 21.02.2020.
//  Copyright © 2020 Mikhail Medvedev. All rights reserved.
//

import SpriteKit
import UIKit

final class BuildingNode: SKSpriteNode {
	private var currentImage: UIImage!

	private func drawBuilding(size: CGSize) -> UIImage {
		let renderer = UIGraphicsImageRenderer(size: size)

		let image = renderer.image { ctx in
			let rectangle = CGRect(x: 0, y: 0, width: size.width, height: size.height)
			let color: UIColor

			switch Int.random(in: 0...2) {
			case 0:
				color = UIColor(hue: 0.502, saturation: 0.98, brightness: 0.67, alpha: 1)
			case 1:
				color = UIColor(hue: 0.999, saturation: 0.99, brightness: 0.67, alpha: 1)
			default:
				color = UIColor(hue: 0, saturation: 0, brightness: 0.67, alpha: 1)
			}

			color.setFill()
			ctx.cgContext.addRect(rectangle)
			ctx.cgContext.drawPath(using: .fill)

			let lightOnColor = UIColor(hue: 0.190, saturation: 0.67, brightness: 0.99, alpha: 1)
			let lightOffColor = UIColor(hue: 0, saturation: 0, brightness: 0.34, alpha: 1)

			for row in stride(from: 10, to: Int(size.height - 10), by: 40) {
				for col in stride(from: 10, to: Int(size.width - 10), by: 40) {
					if Bool.random() {
						lightOnColor.setFill()
					} else {
						lightOffColor.setFill()
					}

					ctx.cgContext.fill(CGRect(x: col, y: row, width: 15, height: 20))
				}
			}
		}

		return image
	}

	private func configurePhysycs() {
		physicsBody = SKPhysicsBody(texture: texture!, size: size)
		physicsBody?.isDynamic = false
		physicsBody?.categoryBitMask = CollisionType.building.rawValue
		physicsBody?.contactTestBitMask = CollisionType.banana.rawValue
	}

	func setup() {
		name = "building"

		currentImage = drawBuilding(size: size)
		texture = SKTexture(image: currentImage)

		configurePhysycs()
	}

}
