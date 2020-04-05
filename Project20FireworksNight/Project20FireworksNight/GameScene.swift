//
//  GameScene.swift
//  Project20FireworksNight
//
//  Created by Mikhail Medvedev on 13.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {

	private var scoreLabel: SKLabelNode!
	private var gameTimer: Timer?
	private var fireworks = [SKNode]()

	private let leftEdge = -22
	private let bottomEdge = -22
	private let rightEdge = 1024 + 22
	private var launches = 0 {
		didSet {
			if launches == 10 {
				gameTimer?.invalidate()
			}
		}
	}

	private var score = 0 {
		didSet {
			scoreLabel.text = "Score: \(score)"
		}
	}

	override func didMove(to view: SKView) {
		let background = SKSpriteNode(imageNamed: "background")
		background.blendMode = .replace
		background.position = CGPoint(x: 512, y: 384)
		background.zPosition = -1
		addChild(background)

		scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
		scoreLabel.text = "Score: 0"
		scoreLabel.position = CGPoint(x: 900, y: 720)
		addChild(scoreLabel)

		gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
	}

	private func createFirework(xMovement: CGFloat, x: Int, y: Int) {
		let node = SKNode()
		node.position = CGPoint(x: x, y: y)

		let fireWork = SKSpriteNode(imageNamed: "rocket")
		fireWork.colorBlendFactor = 1
		fireWork.name = "firework"
		node.addChild(fireWork)

		switch Int.random(in: 0...2) {
		case 0:
			fireWork.color = .yellow
		case 1:
			fireWork.color = .green
		default:
			fireWork.color = .red
		}

		let path = UIBezierPath()
		path.move(to: .zero)
		path.addLine(to: CGPoint(x: xMovement, y: 1000))

		let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
		node.run(move)

		if let emitter = SKEmitterNode(fileNamed: "fuse") {
			emitter.position = CGPoint(x: 0, y: leftEdge)
			node.addChild(emitter)
		}

		fireworks.append(node)
		addChild(node)

	}

	@objc private func launchFireworks() {
		let movementAmount: CGFloat = 1800

		switch Int.random(in: 0...3) {
		case 0:
			// fire five, straight up
			createFirework(xMovement: 0, x: 512, y: bottomEdge)
			createFirework(xMovement: 0, x: 512 - 200, y: bottomEdge)
			createFirework(xMovement: 0, x: 512 - 100, y: bottomEdge)
			createFirework(xMovement: 0, x: 512 + 100, y: bottomEdge)
			createFirework(xMovement: 0, x: 512 + 200, y: bottomEdge)

		case 1:
			// fire five, in a fan
			createFirework(xMovement: 0, x: 512, y: bottomEdge)
			createFirework(xMovement: -200, x: 512 - 200, y: bottomEdge)
			createFirework(xMovement: -100, x: 512 - 100, y: bottomEdge)
			createFirework(xMovement: 100, x: 512 + 100, y: bottomEdge)
			createFirework(xMovement: 200, x: 512 + 200, y: bottomEdge)

		case 2:
			// fire five, from the left to the right
			createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 400)
			createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 300)
			createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 200)
			createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 100)
			createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge)

		case 3:
			// fire five, from the right to the left
			createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 400)
			createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 300)
			createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 200)
			createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 100)
			createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge)

		default:
			break
		}

		launches += 1
	}

	private func checkTouches(_ touches: Set<UITouch>) {
		guard let touch = touches.first else { return }

		let location = touch.location(in: self)
		let nodesInTouch = nodes(at: location)

		for case let node as SKSpriteNode in nodesInTouch {
			guard node.name == "firework" else { continue }

			for parent in fireworks {
				guard let firework = parent.children.first as? SKSpriteNode else { continue }

				if firework.name == "selected" && firework.color != node.color {
					node.name = "firework"
					node.colorBlendFactor = 1
				}
			}

			node.name = "selected"
			node.colorBlendFactor = 0

		}
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		checkTouches(touches)
	}

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesMoved(touches, with: event)
		checkTouches(touches)
	}

	override func update(_ currentTime: TimeInterval) {
		for (index, firework) in fireworks.enumerated().reversed() {
			if firework.position.y > 900 {
				fireworks.remove(at: index)
				firework.removeFromParent()
			}
		}
	}

	private func explode(firework: SKNode) {
		if let emitter = SKEmitterNode(fileNamed: "explode") {
			emitter.position = firework.position
			addChild(emitter)
		}

		firework.removeFromParent()
	}

	func explodeFireworks() {
		var numExploded = 0

		for (index, fireworkContainer) in fireworks.enumerated().reversed() {
			guard let firework = fireworkContainer.children.first as? SKSpriteNode else { continue }

			if firework.name == "selected" {
				explode(firework: fireworkContainer)
				fireworks.remove(at: index)
				numExploded += 1
			}
		}

		switch numExploded {
		case 0:
			// nothing – rubbish!
			break
		case 1:
			score += 200
		case 2:
			score += 500
		case 3:
			score += 1500
		case 4:
			score += 2500
		default:
			score += 4000
		}
	}
}
