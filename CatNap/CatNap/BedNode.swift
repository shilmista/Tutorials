//
//  BedNode.swift
//  CatNap
//
//  Created by Tony Cheng on 4/26/16.
//  Copyright © 2016 shilmista. All rights reserved.
//

import Foundation
import SpriteKit

class BedNode: SKSpriteNode, CustomNodeEvents {
    func didMoveToScene() {
        print("bed added to scene")
        
        let bedBodySize = CGSize(width: 40, height: 30)
        physicsBody = SKPhysicsBody(rectangleOfSize: bedBodySize)
        physicsBody!.dynamic = false
        
        physicsBody!.categoryBitMask = PhysicsCategory.Bed
        physicsBody!.collisionBitMask = PhysicsCategory.None
    }
}
