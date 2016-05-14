//
//  GameOver.swift
//  DropCharge
//
//  Created by Tony Cheng on 5/8/16.
//  Copyright © 2016 shilmista. All rights reserved.
//

import SpriteKit
import GameplayKit
class GameOver: GKState {
    unowned let scene: GameScene
    init(scene: SKScene) {
        self.scene = scene as! GameScene
        super.init()
    }
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        if previousState is Playing {
            scene.playBackgroundMusic("SpaceGame.caf")
            scene.physicsWorld.contactDelegate = nil
            scene.player.physicsBody?.dynamic = false
            let moveUpAction = SKAction.moveByX(0,
                                                y: scene.size.height/2, duration: 0.5)
            moveUpAction.timingMode = .EaseOut
            let moveDownAction = SKAction.moveByX(0,
                                                  y: -(scene.size.height * 1.5), duration: 1.0)
            moveDownAction.timingMode = .EaseIn
            let sequence = SKAction.sequence(
                [moveUpAction, moveDownAction])
            scene.player.runAction(sequence)
            let gameOver = SKSpriteNode(imageNamed: "GameOver")
            gameOver.position = scene.getCameraPosition()
            gameOver.zPosition = 10
            scene.addChild(gameOver)
            
            let explosion = scene.explosion(3.0)
            explosion.position = gameOver.position
            explosion.zPosition = 11
            scene.addChild(explosion)
            scene.runAnim(scene.soundExplosions[3])
        }
    }
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        return stateClass is WaitingForTap.Type
    }
}