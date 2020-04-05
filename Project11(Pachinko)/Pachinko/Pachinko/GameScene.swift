//
//  GameScene.swift
//  Pachinko
//
//  Created by Mikhail Medvedev on 10.11.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate
{
	var scoreLabel = SKLabelNode()
	var editLabel = SKLabelNode()

	var attempts = 5 {
		didSet {
			if oldValue == 1 {
				for node in self.children {
					if node.name == "box" {
						node.removeFromParent()
					}
				}
				attempts = 5
			}
		}
	}


	var isEditingMode = false {
		didSet {
			editLabel.text = isEditingMode ? "Done" : "Edit"
		}
	}
	var score = 0 {
		didSet {
			scoreLabel.text = "Score: \(score)"
		}
	}
	override func didMove(to view: SKView) {
		let background = SKSpriteNode(imageNamed: "background")
		background.position = CGPoint(x: 512, y: 384)
		background.zPosition = -1
		background.blendMode = .replace

		configureScoreLabel()
		configureEditLabel()

		makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
		makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
		makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
		makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)

		for number in 0..<5 {
			let x = number * 256
			makeBouncer(at: CGPoint(x: x, y: 0))
		}

		physicsWorld.contactDelegate = self

		physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
		addChild(background)
	}

	func didBegin(_ contact: SKPhysicsContact) {
		guard let nodeA = contact.bodyA.node else { return }
		guard let nodeB = contact.bodyB.node else { return }

		if nodeA.name == "ball" {
			collision(between: nodeA, object: nodeB)
		} else if nodeB.name == "ball" {
			collision(between: nodeB, object: nodeA)
		}
	}

	private func configureScoreLabel() {
		scoreLabel.fontName = "Chalkduster"
		scoreLabel.horizontalAlignmentMode = .right
		scoreLabel.position = CGPoint(x: 980, y: 700)
		scoreLabel.text = "Score: 0"
		addChild(scoreLabel)
	}

	private func configureEditLabel() {
		editLabel.fontName = "Chalkduster"
		editLabel.text = "Edit"
		editLabel.position = CGPoint(x: 80, y: 700)
		addChild(editLabel)
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let firstTouch = touches.first {
			let location = firstTouch.location(in: self)

			let objects = nodes(at: location)

			if objects.contains(editLabel) {
				isEditingMode.toggle()
			} else {
				if isEditingMode {
					let size = CGSize(width: Int.random(in: 16...168), height: 16)
					let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
					box.zRotation = CGFloat.random(in: 0...3)
					box.position = location
					box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
					box.physicsBody?.isDynamic = false
					box.name = "box"
					addChild(box)
				} else {
					let ballColors = ["ballRed","ballBlue","ballCyan","ballGreen","ballGrey","ballPurple","ballYellow"]
					let ball = SKSpriteNode(imageNamed: ballColors.randomElement() ?? "ballRed")
					ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
					ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
					ball.physicsBody?.restitution = 0.4
					ball.position = location
					ball.position.y = 700
					ball.name = "ball"
					addChild(ball)
				}
			}
		}
	}

	private func makeBouncer(at position: CGPoint) {
		let bouncer = SKSpriteNode(imageNamed: "bouncer")
		bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
		bouncer.position = position
		bouncer.physicsBody?.isDynamic = false
		addChild(bouncer)
	}

	private func makeSlot(at position: CGPoint, isGood: Bool) {
		let slotBase = SKSpriteNode(
			imageNamed: isGood ? "slotBaseGood" : "slotBaseBad"
		)
		let slotGlow =  SKSpriteNode(
			imageNamed: isGood ? "slotGlowGood" : "slotGlowBad"
		)

		slotBase.name = isGood ? "good" : "bad"

		slotBase.position = position
		slotGlow.position = position

		slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
		slotBase.physicsBody?.isDynamic = false

		addChild(slotBase)
		addChild(slotGlow)

		let spin = SKAction.rotate(byAngle: .pi, duration: 10)
		let spinForever = SKAction.repeatForever(spin)
		slotGlow.run(spinForever)
	}

	private func collision(between ball: SKNode, object: SKNode) {
		if object.name == "good" {
			destroy(ball: ball)
			score += 1
		} else if object.name == "bad" {
			destroy(ball: ball)
			score -= 1
		}

		if attempts != 0 {
			if object.name == "box" {
				destroy(ball: ball)
				destroy(ball: object)
				attempts -= 1
			}
		}
	}

	private func destroy(ball: SKNode) {
		if let fireEffect = SKEmitterNode(fileNamed: "FireParticles") {
			fireEffect.position = ball.position
			addChild(fireEffect)
		}
		ball.removeFromParent()
	}
}
