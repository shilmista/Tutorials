//
//  GameScene.swift
//  CatNap
//
//  Created by Tony Cheng on 4/25/16.
//  Copyright (c) 2016 shilmista. All rights reserved.
//

import SpriteKit

protocol CustomNodeEvents {
    func didMoveToScene()
}

protocol InteractiveNode {
    func interact()
}

struct PhysicsCategory {
    static let None: UInt32 = 0
    static let Cat: UInt32 = 0b1
    static let Block: UInt32 = 0b10 // 2
    static let Bed: UInt32 = 0b100 // 4
    static let Edge: UInt32 = 0b1000 // 8
    static let Label: UInt32 = 0b10000 // 16
    static let Spring: UInt32 = 0b100000 // 32
    static let Hook: UInt32 = 0b1000000 // 64
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var bedNode: BedNode!
    var catNode: CatNode!
    var playable = true
    var bounceCount = 0
    var currentLevel: Int = 0
    var hookNode: HookNode?
    
    class func level(levelNum: Int) -> GameScene? {
        let scene = GameScene(fileNamed: "Level\(levelNum)")!
        scene.currentLevel = levelNum
        scene.scaleMode = .AspectFill
        return scene
    }
    
    override func didMoveToView(view: SKView) {
        let maxAspectRatio: CGFloat = 16.0/9.0
        let maxAspectRatioHeight = size.width / maxAspectRatio
        let playableMargin: CGFloat = (size.height - maxAspectRatioHeight)/2
        let playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: size.height - playableMargin * 2)
        physicsBody = SKPhysicsBody(edgeLoopFromRect: playableRect)
        physicsWorld.contactDelegate = self
        physicsBody!.categoryBitMask = PhysicsCategory.Edge
        
        bedNode = childNodeWithName("bed") as! BedNode
        catNode = childNodeWithName("//cat_body") as! CatNode
        
        enumerateChildNodesWithName("//*", usingBlock: {
            node, _ in
            if let customNode = node as? CustomNodeEvents {
                customNode.didMoveToScene()
            }
        })
        
        SKTAudio.sharedInstance().playBackgroundMusic("backgroundMusic.mp3")
        
        hookNode = childNodeWithName("hookBase") as? HookNode
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {

    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    override func didSimulatePhysics() {
        if playable && hookNode?.isHooked != true {
            if fabs(catNode.parent!.zRotation) > CGFloat(25).degreesToRadians() {
                lose()
            }
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if playable {
            if collision == PhysicsCategory.Cat | PhysicsCategory.Bed {
                print("SUCCESS")
                win()
            }
            else if collision == PhysicsCategory.Cat | PhysicsCategory.Edge {
                print("FAIL")
                lose()
            }
            else if collision == PhysicsCategory.Cat | PhysicsCategory.Hook && hookNode?.isHooked == false {
                hookNode!.hookCat(catNode)
            }
        }
        else {
            if collision == PhysicsCategory.Label | PhysicsCategory.Edge {
                bounceCount += 1
                print("label is bouncing \(bounceCount)")
            }
            if bounceCount == 4 {
                enumerateChildNodesWithName("Label", usingBlock: {
                    node, _ in
                    node.removeFromParent()
                })
            }
        }
    }
    
    func inGameMessage(text: String) {
        let message = MessageNode(message: text)
        message.name = "Label"
        message.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMidY(frame))
        addChild(message)
    }
    
    func newGame() {
        view!.presentScene(GameScene.level(currentLevel))
    }
    
    func lose() {
        playable = false
        
//        if currentLevel > 1 {
//            currentLevel -= 1
//        }
        
        // 1
        SKTAudio.sharedInstance().pauseBackgroundMusic()
        runAction(SKAction.playSoundFileNamed("lose.mp3", waitForCompletion: false))
        
        //2
        inGameMessage("Try again...")
        
        //3
        performSelector(#selector(GameScene.newGame), withObject: nil, afterDelay: 5)
        
        
        catNode.wakeUp()
    }
    
    func win() {
        playable = false
        
        if currentLevel < 6 {
            currentLevel += 1
        }
        
        SKTAudio.sharedInstance().pauseBackgroundMusic()
        runAction(SKAction.playSoundFileNamed("win.mp3", waitForCompletion: false))
        inGameMessage("Nice job!")
        
        performSelector(#selector(GameScene.newGame), withObject: nil, afterDelay: 3)
        
        catNode.curlAt(bedNode.position)
    }
}
