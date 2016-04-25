//
//  MainMenuScene.swift
//  Tutorials
//
//  Created by Tony Cheng on 4/24/16.
//  Copyright © 2016 shilmista. All rights reserved.
//

import Foundation
import SpriteKit


class MainMenuScene: SKScene {

    override func didMoveToView(view: SKView) {
        var background: SKSpriteNode
        
        background = SKSpriteNode(imageNamed: "MainMenu")
        background.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        addChild(background)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        let gameScene = GameScene(size: self.size)
        gameScene.scaleMode = self.scaleMode
        let reveal = SKTransition.doorwayWithDuration(1.5)
        self.view?.presentScene(gameScene, transition: reveal)
    }
}

