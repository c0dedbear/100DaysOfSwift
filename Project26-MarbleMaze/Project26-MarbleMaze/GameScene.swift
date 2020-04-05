//
//  GameScene.swift
//  Project26-MarbleMaze
//
//  Created by Mikhail Medvedev on 05.01.2020.
//  Copyright © 2020 Mikhail Medvedev. All rights reserved.
//

import CoreMotion
import SpriteKit

enum CollisionTypes: UInt32 {
    case player = 1
    case wall = 2
    case star = 4
    case vortex = 8
    case finish = 16
	case teleport = 32
}

class GameScene: SKScene {

	var coreMotionManager = CMMotionManager()

	var isGameOver = false
	var player: SKSpriteNode!
	var scoreLabel: SKLabelNode!
	var currentLevel = 1
	var isTeleporting = false

	var score = 0 {
		didSet {
			scoreLabel.text = "Score: \(score)"
		}
	}

    override func didMove(to view: SKView) {
		addBackground()
		createLabel()
		loadLevel(currentLevel)
		createPlayer()
		physicsWorld.gravity = .zero
		physicsWorld.contactDelegate = self
		coreMotionManager.startAccelerometerUpdates()
    }

	#if targetEnvironment(simulator)
	var lastTouchPosition: CGPoint? // only for simulator
	//  only for simulator
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first else { return }
		let location = touch.location(in: self)
		lastTouchPosition = location
	}

	//  only for simulator
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first else { return }
		let location = touch.location(in: self)
		lastTouchPosition = location
	}

	//  only for simulator
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		lastTouchPosition = nil
	}
	#endif

	override func update(_ currentTime: TimeInterval) {
		guard isGameOver == false else { return }

		#if targetEnvironment(simulator)
		if let currentTouch = lastTouchPosition {
			let diff = CGPoint(x: currentTouch.x - player.position.x, y: currentTouch.y - player.position.y)
			physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
		}
		#else
		if let accelerometerData = coreMotionManager.accelerometerData {
			physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
		}
		#endif
	}

	private func loadNextLevel() {
		removeAllChildren()
		isGameOver = false
		addBackground()
		loadLevel(currentLevel + 1)
		createLabel()
		createPlayer()
	}

	private func addBackground() {
		let background = SKSpriteNode(imageNamed: "background.jpg")
		background.position = CGPoint(x: 512, y: 384)
		background.blendMode = .replace
		background.zPosition = -1
		addChild(background)
	}

	private func createLabel() {
		scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
		scoreLabel.horizontalAlignmentMode = .left
		scoreLabel.position = CGPoint(x: 16, y: 16)
		scoreLabel.zPosition = 2
		addChild(scoreLabel)
		score += 0
	}

	private func createPlayer() {
		player = SKSpriteNode(imageNamed: "player")
		player.position = CGPoint(x: 96, y: 672)
		player.zPosition = 1
		player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
		player.physicsBody?.allowsRotation = false
		player.physicsBody?.linearDamping = 0.5

		player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
		player.physicsBody?.contactTestBitMask = CollisionTypes.star.rawValue | CollisionTypes.vortex.rawValue | CollisionTypes.finish.rawValue
		player.physicsBody?.collisionBitMask = CollisionTypes.wall.rawValue
		addChild(player)
	}

	private func loadLevel(_ level: Int) {
		let lines = getLevelLines(level: level)

		for (row, line) in lines.reversed().enumerated() {
			for (column, letter) in line.enumerated() {
				let position = CGPoint(x: (64 * column) + 32, y: (64 * row) + 32)

				if letter == "x" {
					loadWall(on: position)
				} else if letter == "v"  {
					loadVortex(on: position)
				} else if letter == "s"  {
					loadStar(on: position)
				} else if letter == "f"  {
					loadFinish(on: position)
				}  else if letter == "t"  {
					loadTeleport(on: position)
				}
				else if letter == " " {
					// this is an empty space – do nothing!
				} else {
					fatalError("Unknown level letter: \(letter)")
				}
			}
		}

		showNextLevelTitle(for: level)
	}

	private func showNextLevelTitle(for level: Int) {
		let levelLabel = SKLabelNode(fontNamed: "Chalkduster")
		levelLabel.text = "Level \(level)"
		levelLabel.fontSize = 88
		levelLabel.horizontalAlignmentMode = .center
		levelLabel.position = CGPoint(x: 512, y: 384)
		levelLabel.zPosition = 2
		addChild(levelLabel)

		DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
			let scale = SKAction.scale(by: 0.0001, duration: 0.5)
			levelLabel.run(scale) { levelLabel.removeFromParent() }
		}
	}

	private func getLevelLines(level: Int) -> [String] {
		guard let levelURL = Bundle.main.url(forResource: "level\(level)", withExtension: "txt") else { fatalError("Could not find level1.txt") }
		guard let levelString = try? String(contentsOf: levelURL) else { fatalError("Could not load String from level\(level).txt") }

		return  levelString.components(separatedBy: "\n")
	}

	private func loadWall(on position: CGPoint) {
		let node = SKSpriteNode(imageNamed: "block")
		node.position = position
		node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
		node.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
		node.physicsBody?.isDynamic = false
		addChild(node)
	}

	private func loadVortex(on position: CGPoint) {
		let node = SKSpriteNode(imageNamed: "vortex")
		node.position = position
		node.name = "vortex"
		node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
		node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
		node.physicsBody?.isDynamic = false

		node.physicsBody?.categoryBitMask = CollisionTypes.vortex.rawValue
		// get notification when vortex node make contact with player node
		node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
		node.physicsBody?.collisionBitMask = 0
		addChild(node)
	}

	private func loadStar(on position: CGPoint) {
		let node = SKSpriteNode(imageNamed: "star")
		node.position = position
		node.name = "star"
		node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
		node.physicsBody?.isDynamic = false

		node.physicsBody?.categoryBitMask = CollisionTypes.star.rawValue
		node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
		node.physicsBody?.collisionBitMask = 0
		addChild(node)
	}

	private func loadFinish(on position: CGPoint) {
		let node = SKSpriteNode(imageNamed: "finish")
		node.position = position
		node.name = "finish"
		node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
		node.physicsBody?.isDynamic = false

		node.physicsBody?.categoryBitMask = CollisionTypes.finish.rawValue
		node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
		node.physicsBody?.collisionBitMask = 0
		addChild(node)
	}

	private func loadTeleport(on position: CGPoint) {
		//MARK: load teleport
		let node = SKSpriteNode(imageNamed: "teleport")
		node.position = position
		node.name = "teleport"
		node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)

		let pulseUp = SKAction.scale(to: 1, duration: 1.0)
		let pulseDown = SKAction.scale(to: 0.75, duration: 1.0)
		let pulse = SKAction.sequence([pulseUp, pulseDown])
		let repeatPulse = SKAction.repeatForever(pulse)

		node.run(repeatPulse)
		node.physicsBody?.isDynamic = false

		node.physicsBody?.categoryBitMask = CollisionTypes.teleport.rawValue
		node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
		node.physicsBody?.collisionBitMask = 0
		addChild(node)
	}

	private func playerCollided(with node: SKNode) {
		let move = SKAction.move(to: node.position, duration: 0.25)
		let scale = SKAction.scale(to: 0.0001, duration: 0.25)
		let remove = SKAction.removeFromParent()
		let sequence = SKAction.sequence([move, scale, remove])

		if node.name == "vortex" {
			player.physicsBody?.isDynamic = false
			isGameOver = true
			score -= 1

			player.run(sequence) { [weak self] in
				self?.createPlayer()
				self?.isGameOver = false
			}
		} else if node.name == "star" {
			node.removeFromParent()
			score += 1
		} else if node.name == "teleport" {
			//MARK: MAKE TELEPORT
			guard isTeleporting == false else { return }
			for case let teleportNode as SKSpriteNode in children {
				if teleportNode.name == "teleport" && node.position != teleportNode.position {
					isTeleporting = true
					player.run(sequence) { [weak self] in
						self?.createPlayer()
						self?.player.position = CGPoint(x: teleportNode.position.x, y: teleportNode.position.y)
						DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
							self?.isTeleporting = false
						}
					}
				}
			}
		} else if node.name == "finish" {
			// next level?
			isGameOver = true
			score += 10
			loadNextLevel()
		}
	}
}

extension GameScene: SKPhysicsContactDelegate
{
	func didBegin(_ contact: SKPhysicsContact) {
		guard let nodeA = contact.bodyA.node else { return }
		guard let nodeB = contact.bodyB.node else { return }

		if nodeA == player {
			playerCollided(with: nodeB)
		} else if nodeB == player {
			playerCollided(with: nodeA)
		}
	}
}
