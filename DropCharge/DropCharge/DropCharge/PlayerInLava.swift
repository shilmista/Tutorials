//
//  PlayerInLava.swift
//  DropCharge
//
//  Created by Tony Cheng on 5/8/16.
//  Copyright © 2016 shilmista. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class PlayerInLava: GKState {
    
    unowned let scene: GameScene
    
    init(scene: SKScene) {
        self.scene = scene as! GameScene
        super.init()
    }
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        scene.playerTrail.particleBirthRate = 0
        SKTAudio.sharedInstance().playSoundEffect("DrownFireBug.mp3")
        
        let smokeTrail = scene.addTrail("SmokeTrail")
        scene.runAction(SKAction.sequence([
            SKAction.waitForDuration(3.0),
            SKAction.runBlock() {
                self.scene.removeTrail(smokeTrail)
            }
            ]))
        
        scene.boostPlayer()
        scene.lives -= 1
                
        scene.screenShakeByAmt(50)
    }
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        return stateClass is PlayerJump.Type || stateClass is PlayerDead.Type
    }
}
