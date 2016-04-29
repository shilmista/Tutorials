//
//  HintNode.swift
//  CatNap
//
//  Created by Tony Cheng on 4/28/16.
//  Copyright © 2016 shilmista. All rights reserved.
//

import UIKit

import SpriteKit
class HintNode: SKSpriteNode, CustomNodeEvents, InteractiveNode {

    var shape: SKShapeNode = SKShapeNode()
    func didMoveToScene() {
        color = SKColor.clearColor()
        
        shape = SKShapeNode(path: arrowPath)
        shape.strokeColor = SKColor.grayColor()
        shape.lineWidth = 4
        shape.fillColor = SKColor.whiteColor()
        shape.fillTexture = SKTexture(imageNamed: "wood_tinted")
        shape.alpha = 0.8
        addChild(shape)
        
        let move = SKAction.moveByX(-40, y: 0, duration: 1)
        let bounce = SKAction.sequence([
            move,
            move.reversedAction()
            ])
        let bounceAction = SKAction.repeatAction(bounce, count: 3)
        shape.runAction(bounceAction, completion: {
            self.removeFromParent()
        })
        
        self.userInteractionEnabled = true
    }

    var arrowPath: CGPath {
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPoint(x: 0.5, y: 65.69))
        bezierPath.addLineToPoint(CGPoint(x: 74.99, y: 1.5))
        bezierPath.addLineToPoint(CGPoint(x: 74.99, y: 38.66))
        bezierPath.addLineToPoint(CGPoint(x: 257.5, y: 38.66))
        bezierPath.addLineToPoint(CGPoint(x: 257.5, y: 92.72))
        bezierPath.addLineToPoint(CGPoint(x: 74.99, y: 92.72))
        bezierPath.addLineToPoint(CGPoint(x: 74.99, y: 126.5))
        bezierPath.addLineToPoint(CGPoint(x: 0.5, y: 65.69))
        bezierPath.closePath()
        return bezierPath.CGPath
    }
    
    func interact() {
        let colors = [SKColor.redColor(), SKColor.greenColor(), SKColor.yellowColor()]
        let randomIndex = Int.random(3)
        let color = colors[randomIndex]
        
        shape.fillColor = color
        print("tapped random color \(color)")
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event:
        UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        interact()
    }
    
}
