//
//  PlayerJump.swift
//  DropCharge
//
//  Created by Tony Cheng on 5/8/16.
//  Copyright © 2016 shilmista. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class PlayerJump: GKState {
    
    unowned let scene: GameScene
    
    init(scene: SKScene) {
        self.scene = scene as! GameScene
        super.init()
    }
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        scene.runSquashAndStretch()        
        if scene.playerTrail.particleBirthRate == 0 {
            scene.playerTrail.particleBirthRate = 200
        }
        
        if previousState is PlayerInLava {
            return
        }
    }
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        if abs(scene.player.physicsBody!.velocity.dx) > 100.0 {
            if (scene.player.physicsBody!.velocity.dx > 0) {
                scene.runAnim(scene.animSteerRight)
            } else {
                scene.runAnim(scene.animSteerLeft)
            }
        } else {
            scene.runAnim(scene.animJump)
        }
    }
        
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        return stateClass is PlayerFall.Type
    }
}
