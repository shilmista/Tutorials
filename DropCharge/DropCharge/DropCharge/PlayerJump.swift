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
        
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        return stateClass is PlayerFall.Type
    }
}
