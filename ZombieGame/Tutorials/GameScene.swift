//
//  GameScene.swift
//  Tutorials
//
//  Created by Tony Cheng on 4/24/16.
//  Copyright (c) 2016 shilmista. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var zombie:SKSpriteNode = SKSpriteNode()
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    let zombieMovePointsPerSec: CGFloat = 600.0
    let catMovePointsPerSec: CGFloat = 600.0

    var velocity = CGPoint.zero
    var lastTouchLocation = CGPoint.zero
    let playableRect: CGRect
    let zombieRotateRadiansPerSec: CGFloat = 4.0 * π
    var currentAngle: CGFloat = 0
    let zombieAnimation: SKAction
    let catCollisionSound: SKAction = SKAction.playSoundFileNamed("hitCat.wav", waitForCompletion: false)
    let enemyCollisionSound: SKAction = SKAction.playSoundFileNamed("hitCatLady.wav", waitForCompletion: false)
    var invincible: Bool = false
    var lives = 5
    var gameOver = false
    let cameraMovePointsPerSec: CGFloat = 200.0

    // chapter 5
    let cameraNode = SKCameraNode()

    // chapter 6
    let livesLabel = SKLabelNode(fontNamed: "Glimstick")
    let catsLabel = SKLabelNode(fontNamed: "Glimstick")

    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0/9.0 // 1
        let playableHeight = size.width / maxAspectRatio // 2
        let playableMargin = (size.height-playableHeight)/2.0 // 3
        playableRect = CGRect(x: 0, y: playableMargin,
                width: size.width,
                height: playableHeight) // 4
        
        var textures:[SKTexture] = []
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        textures.append(textures[2])
        textures.append(textures[1])
        zombieAnimation = SKAction.animateWithTextures(textures, timePerFrame: 0.1)
        
        super.init(size: size) // 5
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented") // 6
    }

    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        backgroundColor = SKColor.blackColor();
        
        playBackgroundMusic("backgroundMusic.mp3")


        for i in 0...1 {
            let background = backgroundNode()
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: CGFloat(i) * background.size.width, y: 0)
            background.zPosition = -1
            background.name = "background"
            addChild(background)
        }

        zombie = SKSpriteNode(imageNamed: "zombie1")
        zombie.position = CGPoint(x:400, y:400)
        zombie.zPosition = 100
        addChild(zombie)
        
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(spawnEnemy),
            SKAction.waitForDuration(2)
            ])))
        
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(spawnCat),
            SKAction.waitForDuration(1)])))

        addChild(cameraNode)
        self.camera = cameraNode
        setCameraPosition(CGPoint(x: size.width/2, y: size.height/2))

        livesLabel.text = "Lives: \(lives)"
        livesLabel.fontColor = SKColor.blackColor()
        livesLabel.fontSize = 100
        livesLabel.zPosition = 100
        livesLabel.position = CGPoint(x: -playableRect.size.width/2 + CGFloat(20), y: -playableRect.size.height/2 + CGFloat(20) + overlapAmount()/2)
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        livesLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Bottom
        cameraNode.addChild(livesLabel)

        catsLabel.fontColor = SKColor.blackColor()
        catsLabel.fontSize = 100
        catsLabel.zPosition = 100
        catsLabel.position = CGPoint(x: playableRect.size.width/2 - CGFloat(20), y: -playableRect.size.height/2 + CGFloat(20) + overlapAmount()/2)
        catsLabel.horizontalAlignmentMode = .Right
        catsLabel.verticalAlignmentMode = .Bottom
        cameraNode.addChild(catsLabel)
    }

    func backgroundNode() -> SKSpriteNode {
        let backgroundNode = SKSpriteNode()
        backgroundNode.anchorPoint = CGPoint.zero
        backgroundNode.name = "background"

        let background1 = SKSpriteNode(imageNamed: "background1")
        background1.anchorPoint = CGPoint.zero
        background1.position = CGPoint(x: 0, y: 0)
        backgroundNode.addChild(background1)

        let background2 = SKSpriteNode(imageNamed: "background2")
        background2.anchorPoint = CGPoint.zero
        background2.position = CGPoint(x: background1.size.width, y: 0)
        backgroundNode.addChild(background2)

        backgroundNode.size = CGSize(width: background1.size.width + background2.size.width,
                height: background1.size.height)
        return backgroundNode
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */

        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.locationInNode(self)
        sceneTouched(touchLocation)
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.locationInNode(self)
        sceneTouched(touchLocation)
    }
    
    override func didEvaluateActions() {
        checkCollisions()
    }
    
    func sceneTouched(touchLocation: CGPoint) {
        lastTouchLocation = touchLocation
        moveZombieToward(touchLocation)
    }
    
    func moveZombieToward(location: CGPoint) {
        let offset = location - zombie.position
        velocity = offset.normalized() * zombieMovePointsPerSec
        startZombieAnimation()
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if (lastUpdateTime > 0) {
            dt = currentTime - lastUpdateTime
        }
        else {
            dt = 0
        }
        lastUpdateTime = currentTime

/*
        if lastTouchLocation != CGPoint.zero {
            let distance = lastTouchLocation - zombie.position
            if (distance.length() <= CGFloat(zombieMovePointsPerSec * CGFloat(dt))) {
                zombie.position = lastTouchLocation
                velocity *= 0
                boundsCheckZombie()
                stopZombieAnimation()
            }
            else {
                moveSprite(zombie, velocity: velocity)
                boundsCheckZombie()
                rotateSprite(zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)
            }
        }
*/

        moveSprite(zombie, velocity: velocity)
        boundsCheckZombie()
        rotateSprite(zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)

        moveTrain()
        moveCamera()
        if lives <= 0 && !gameOver {
            gameOver = true
            print("you lose!")
            
            backgroundMusicPlayer.stop()
            let gameOverScene = GameOverScene(size: self.size, won: false)
            gameOverScene.scaleMode = self.scaleMode
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    func rotateSprite(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
        let shortestAngle = shortestAngleBetween(currentAngle, angle2: direction.angle)
        let absShortest = shortestAngle * shortestAngle.sign()
        var amountToRotate = zombieRotateRadiansPerSec * CGFloat(dt)
        
        if (amountToRotate > absShortest) {
            amountToRotate = shortestAngle
        }
        else {
            amountToRotate *= shortestAngle.sign()
        }
        
        sprite.zRotation += amountToRotate
        currentAngle = sprite.zRotation
    }

    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
        sprite.position += velocity * CGFloat(dt)
    }

    func boundsCheckZombie() {
        let bottomLeft = CGPoint(x: CGRectGetMinX(cameraRect), y: CGRectGetMinY(cameraRect))
        let topRight = CGPoint(x: CGRectGetMaxX(cameraRect), y: CGRectGetMaxY(cameraRect))

        if zombie.position.x <= bottomLeft.x {
            zombie.position.x = bottomLeft.x
            velocity.x *= -1
        }
        if zombie.position.x >= topRight.x {
            zombie.position.x = topRight.x
            velocity.x *= -1
        }
        if zombie.position.y <= bottomLeft.y {
            zombie.position.y = bottomLeft.y
            velocity.y *= -1
        }
        if zombie.position.y >= topRight.y {
            zombie.position.y = topRight.y
            velocity.y *= -1
        }
    }
    
    func startZombieAnimation() {
        if zombie.actionForKey("animation") == nil {
            zombie.runAction(
                SKAction.repeatActionForever(zombieAnimation),
                withKey:  "animation"
            )
        }
    }
    
    func stopZombieAnimation() {
        zombie.removeActionForKey("animation")
    }
    
    func spawnCat() {
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.name = "cat"
        cat.position = CGPoint(
            x: CGFloat.random(min: CGRectGetMinX(cameraRect),
                max: CGRectGetMaxX(cameraRect)),
            y: CGFloat.random(min: CGRectGetMinY(cameraRect),
                max: CGRectGetMaxY(cameraRect)))
        cat.setScale(0)
        addChild(cat)
        
        // 2
        let appear = SKAction.scaleTo(1.0, duration: 0.5)
        
        cat.zRotation = -π / 16.0
        let leftWiggle = SKAction.rotateByAngle(π/8, duration: 0.5)
        let rightWiggle = leftWiggle.reversedAction()
        let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
        
        let scaleUp = SKAction.scaleBy(1.2, duration: 0.25)
        let scaleDown = scaleUp.reversedAction()
        let fullScale = SKAction.sequence(
            [scaleUp, scaleDown, scaleUp, scaleDown])
        let group = SKAction.group([fullScale, fullWiggle])
        let groupWait = SKAction.repeatAction(group, count: 10)
        
        let disappear = SKAction.scaleTo(0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        let actions = [appear, groupWait, disappear, removeFromParent]
        cat.runAction(SKAction.sequence(actions))
    }
    
    func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.position = CGPoint(x: CGRectGetMaxX(cameraRect) + enemy.size.width/2,
                                 y: CGFloat.random(min: CGRectGetMinY(cameraRect) + enemy.size.height/2, max: CGRectGetMaxY(cameraRect) - enemy.size.height/2)
        )
        enemy.name = "enemy"
        addChild(enemy)
        
        let actionMove = SKAction.moveTo(CGPoint(x:CGRectGetMinX(cameraRect) - enemy.size.width/2, y: enemy.position.y), duration: 2)
        let actionRemove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([actionMove, actionRemove])
        enemy.runAction(sequence)
    }
    
    func blink() {
        self.invincible = true
        
        let blinkTimes = 10.0
        let duration = 3.0
        let blinkAction = SKAction.customActionWithDuration(duration) {
            node, elapsedTime in
            let slice = duration / blinkTimes
            let remainder = Double(elapsedTime) % slice
            node.hidden = remainder > slice / 2
        }
        let turnVulnerable = SKAction.runBlock {
            self.zombie.hidden = false
            self.invincible = false
        }
        zombie.runAction(SKAction.sequence([blinkAction, turnVulnerable]))
    }
    
    func checkCollisions() {
        var hitCats: [SKSpriteNode] = []
        enumerateChildNodesWithName("cat") { node, _ in
            let cat = node as! SKSpriteNode
            if CGRectIntersectsRect(cat.frame, self.zombie.frame) {
                hitCats.append(cat)
            }
        }
        for cat in hitCats {
            zombieHitCat(cat)
        }
        
        if !self.invincible {
            var hitEnemies: [SKSpriteNode] = []
            enumerateChildNodesWithName("enemy") { node, _ in
                let enemy = node as! SKSpriteNode
                if CGRectIntersectsRect(
                    CGRectInset(node.frame, 20, 20), self.zombie.frame) {
                    hitEnemies.append(enemy)
                }
            }
            for enemy in hitEnemies {
                zombieHitEnemy(enemy)
            }
        }
    }
    
    func zombieHitCat(cat: SKSpriteNode) {
        cat.name = "train"
        cat.removeAllActions()
        cat.setScale(1)
        cat.zRotation = 0
        let turnGreen = SKAction.colorizeWithColor(SKColor.greenColor(), colorBlendFactor: 1, duration: 0.2)
        cat.runAction(turnGreen)
        
        runAction(catCollisionSound)
    }
    
    func zombieHitEnemy(enemy: SKSpriteNode) {
        runAction(enemyCollisionSound)
        if !invincible {
            blink()
            loseCats()
            lives -= 1
        }
    }

    func loseCats() {
        var loseCount = 0
        enumerateChildNodesWithName("train") {
            node, stop in
            var randomSpot = node.position
            randomSpot.x += CGFloat.random(min: -100, max: 100)
            randomSpot.y += CGFloat.random(min: -100, max: 100)
            node.name = ""
            node.runAction(SKAction.sequence([
                SKAction.group([
                    SKAction.rotateByAngle(π*4, duration: 1),
                    SKAction.moveTo(randomSpot, duration: 1),
                    SKAction.scaleTo(0, duration: 1)
                ]),
                SKAction.removeFromParent()
            ]))
            loseCount += 1
            if loseCount >= 2 {
                stop.memory = true
            }
        }
    }
    
    func moveTrain() {
        var targetPosition = zombie.position
        var trainCount = 0
        enumerateChildNodesWithName("train") {
            node, _ in
            if !node.hasActions() {
                let actionDuration = 0.3
                let offset = targetPosition - node.position
                let direction = offset.normalized()
                let amountToMovePerSec = direction * self.catMovePointsPerSec// c
                let amountToMove = amountToMovePerSec * CGFloat(actionDuration)// d
                let moveAction = SKAction.moveByX(amountToMove.x, y: amountToMove.y, duration: actionDuration)// e
                node.runAction(moveAction)
            }
            targetPosition = node.position
            trainCount += 1
        }
        
        if trainCount >= 15 && !gameOver {
            gameOver = true
            print("you win!")
            
            backgroundMusicPlayer.stop()
            let gameOverScene = GameOverScene(size: self.size, won: true)
            gameOverScene.scaleMode = self.scaleMode
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }

        livesLabel.text = "Lives: \(lives)"
        catsLabel.text = "Cats: \(trainCount)"
    }

    func moveCamera() {
        let backgroundVelocity = CGPoint(x: cameraMovePointsPerSec, y: 0)
        let amountToMove = backgroundVelocity * CGFloat(dt)
        cameraNode.position += amountToMove

        enumerateChildNodesWithName("background") {
            node, _ in
            let background = node as! SKSpriteNode
            if background.position.x + background.size.width < self.cameraRect.origin.x {
                background.position = CGPoint(x: background.position.x + background.size.width * 2,
                        y: background.position.y)
            }
        }
    }

    func overlapAmount() -> CGFloat {
        guard let view = self.view else {
            return 0 }
        let scale = view.bounds.size.width / self.size.width
        let scaledHeight = self.size.height * scale
        let scaledOverlap = scaledHeight - view.bounds.size.height
        return scaledOverlap / scale
    }
    func getCameraPosition() -> CGPoint {
        return CGPoint(x: cameraNode.position.x, y: cameraNode.position.y +
                overlapAmount()/2)
    }
    func setCameraPosition(position: CGPoint) {
        cameraNode.position = CGPoint(x: position.x, y: position.y -
                overlapAmount()/2)
    }

    var cameraRect: CGRect {
        return CGRect(x: getCameraPosition().x - size.width/2 + (size.width - playableRect.width)/2,
                y: getCameraPosition().y - size.height/2 + (size.height - playableRect.height)/2,
                width: playableRect.width,
                height: playableRect.height)
    }
}
