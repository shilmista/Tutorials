//
//  CatNode.swift
//  CatNap
//
//  Created by Tony Cheng on 4/26/16.
//  Copyright © 2016 shilmista. All rights reserved.
//

import Foundation
import SpriteKit

let kCatTappedNotification = "kCatTappedNotification"

class CatNode: SKSpriteNode, CustomNodeEvents, InteractiveNode {
    func didMoveToScene() {
        print("cat added to scene")
        let catBodyTexture = SKTexture(imageNamed: "cat_body_outline")
        parent!.physicsBody = SKPhysicsBody(texture: catBodyTexture, size: catBodyTexture.size())
        parent!.physicsBody!.categoryBitMask = PhysicsCategory.Cat
        parent!.physicsBody!.collisionBitMask = PhysicsCategory.Block|PhysicsCategory.Edge|PhysicsCategory.Spring
        parent!.physicsBody!.contactTestBitMask = PhysicsCategory.Bed|PhysicsCategory.Edge
        userInteractionEnabled = true
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event:
        UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        interact()
    }
    
    func interact() {
        NSNotificationCenter.defaultCenter().postNotificationName(kCatTappedNotification, object: nil)
    }
    
    func wakeUp() {
        // 1
        for child in children {
            child.removeFromParent()
        }
        texture = nil
        color = SKColor.clearColor()
        
        // 2
        let catAwake = SKSpriteNode(fileNamed: "CatWakeUp")!.childNodeWithName("cat_awake")
        
        // 3
        catAwake?.moveToParent(self)
        catAwake?.position = CGPoint(x: -30, y: 100)
    }
    
    func curlAt(scenePoint: CGPoint) {
        print("current rotation \(parent!.zRotation)")
        parent!.physicsBody = nil
        for child in children {
            child.removeFromParent()
        }
        texture = nil
        color = SKColor.clearColor()
        
        let catCurl = SKSpriteNode(fileNamed: "CatCurl")!.childNodeWithName("cat_curl")
        catCurl?.moveToParent(self)
        catCurl?.position = CGPoint(x: -30, y: 100)

        var localPoint = parent!.convertPoint(scenePoint, fromNode: scene!)
        localPoint.y += frame.size.height/3
        
        runAction(SKAction.group([
            SKAction.moveTo(localPoint, duration: 0.66),
            SKAction.rotateToAngle(-parent!.zRotation, duration: 0.5)
            ]))
    }
}