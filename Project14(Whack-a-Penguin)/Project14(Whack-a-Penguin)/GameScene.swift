//
//  GameScene.swift
//  Project14(Whack-a-Penguin)
//
//  Created by Mikhail Medvedev on 26.11.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {

	var scoreLabel: SKLabelNode!

	var score = 0 {
		didSet {
			scoreLabel.text = "Score: \(score)"
		}
	}

    override func didMove(to view: SKView) {
		let background = SKSpriteNode(imageNamed: "whackBackground")
		background.position = CGPoint(x: 512, y: 384)
		background.blendMode = .replace
		background.zPosition = -1
		addChild(background)

		scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
		scoreLabel.fontSize = 48
		scoreLabel.text = "Score: 0"
		scoreLabel.position = CGPoint(x: 8, y: 8)
		scoreLabel.horizontalAlignmentMode = .left
		addChild(scoreLabel)

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
}
