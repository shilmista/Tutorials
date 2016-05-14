//
//  PlayerFall.swift
//  DropCharge
//
//  Created by Tony Cheng on 5/8/16.
//  Copyright © 2016 shilmista. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class PlayerFall: GKState {
    
    unowned let scene: GameScene
    
    init(scene: SKScene) {
        self.scene = scene as! GameScene
        super.init()
    }
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        scene.runAnim(scene.animFall)
    }
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        return stateClass is PlayerInLava.Type || stateClass is PlayerJump.Type
    }
}
