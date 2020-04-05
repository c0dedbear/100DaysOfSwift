//
//  GameScene.swift
//  Project17-SpaceRace
//
//  Created by Mikhail Medvedev on 02.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {

	var starfield: SKEmitterNode!
	var player: SKSpriteNode!
	var scoreLabel: SKLabelNode!

	var possibleEnemies = ["ball", "hammer", "tv"]
	var timer: Timer?
	var isGameOver = false

	var score = 0 {
		didSet {
			scoreLabel.text = "Score: \(score)"
		}
	}
    
    override func didMove(to view: SKView) {
		starfield = SKEmitterNode(fileNamed: "starfield")!
		starfield.position = CGPoint(x: 1024, y: 384)
		starfield.advanceSimulationTime(10)
		addChild(starfield)
		starfield.zPosition = -1

		player = SKSpriteNode(imageNamed: "player")
		player.position = CGPoint(x: 100, y: 384)
		player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
		player.physicsBody?.contactTestBitMask = 1
		addChild(player)

		scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
		scoreLabel.position = CGPoint(x: 16, y: 16)
		scoreLabel.horizontalAlignmentMode = .left
		addChild(scoreLabel)

		score = 0

		timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)

		physicsWorld.gravity = CGVector(dx: 0, dy: 0)
		physicsWorld.contactDelegate = self

    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
		for node in children {
			if node.position.x < -300 {
				node.removeFromParent()
			}
		}

		if isGameOver == false {
			score += 1
		}
    }

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first else { return }

		var location = touch.location(in: self)

		if location.y < 100 {
			location.y = 100
		} else if location.y > 668 {
			location.y = 668
		}

		player.position = location
	}

	@objc private func createEnemy() {
		guard let enemy = possibleEnemies.randomElement() else { return }
		guard isGameOver == false else {
			timer?.invalidate()
			return
		}

		let sprite = SKSpriteNode(imageNamed: enemy)
		sprite.position = CGPoint(x: 1200, y: Int.random(in: 50...736))
		addChild(sprite)

		sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)

		sprite.physicsBody?.categoryBitMask = 1
		sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
		sprite.physicsBody?.angularVelocity = 5
		sprite.physicsBody?.linearDamping = 0
		sprite.physicsBody?.angularDamping = 0

	}
}

extension GameScene : SKPhysicsContactDelegate
{

	func didBegin(_ contact: SKPhysicsContact) {
		let explostion = SKEmitterNode(fileNamed: "explosion")!
		explostion.position = player.position
		addChild(explostion)

		player.removeFromParent()

		isGameOver = true
	}
}
