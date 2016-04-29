//
//  PictureNode.swift
//  CatNap
//
//  Created by Tony Cheng on 4/28/16.
//  Copyright © 2016 shilmista. All rights reserved.
//

import UIKit

import SpriteKit
class PictureNode: SKSpriteNode, CustomNodeEvents, InteractiveNode {
    func didMoveToScene() {
        userInteractionEnabled = true
        
        let pictureNode = SKSpriteNode(imageNamed: "picture")
        let maskNode = SKSpriteNode(imageNamed: "picture-frame-mask")
        
        let cropNode = SKCropNode()
        cropNode.addChild(pictureNode)
        cropNode.maskNode = maskNode
        addChild(cropNode)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event:
        UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        interact()
    }
    
    func interact() {
        userInteractionEnabled = false
        physicsBody!.dynamic = true
    }

}