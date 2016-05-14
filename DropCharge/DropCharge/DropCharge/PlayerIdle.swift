//
//  PlayerIdle.swift
//  DropCharge
//
//  Created by Tony Cheng on 5/8/16.
//  Copyright © 2016 shilmista. All rights reserved.
//

import SpriteKit
import GameplayKit

class PlayerIdle: GKState {
    
    unowned let scene: GameScene
    
    init(scene: SKScene) {
        self.scene = scene as! GameScene
        super.init()
    }
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        print("entered idle state")
        scene.player.physicsBody = SKPhysicsBody(circleOfRadius: scene.player.size.width * 0.3)
        scene.player.physicsBody!.dynamic = false
        scene.player.physicsBody!.allowsRotation = false
        scene.player.physicsBody!.categoryBitMask = PhysicsCategory.Player
        scene.player.physicsBody!.collisionBitMask = 0
        
        scene.playerTrail = scene.addTrail("PlayerTrail")
    }
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        return stateClass is PlayerJump.Type
    }
}
