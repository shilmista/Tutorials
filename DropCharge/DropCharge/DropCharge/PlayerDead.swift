//
//  PlayerDead.swift
//  DropCharge
//
//  Created by Tony Cheng on 5/8/16.
//  Copyright © 2016 shilmista. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class PlayerDead: GKState {
    
    unowned let scene: GameScene
    
    init(scene: SKScene) {
        self.scene = scene as! GameScene
        super.init()
    }

    override func didEnterWithPreviousState(previousState: GKState?) {
        scene.runAction(scene.soundGameOver)
    }
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        return stateClass is PlayerIdle.Type
    }
}
