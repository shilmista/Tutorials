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
    let zombieMovePointsPerSec: CGFloat = 480.0
    let catMovePointsPerSec: CGFloat = 480.0

    var velocity = CGPoint.zero
    var lastTouchLocation = CGPoint.zero
    let playableRect: CGRect
    let zombieRotateRadiansPerSec: CGFloat = 4.0 * π
    var currentAngle: CGFloat = 0
    let zombieAnimation: SKAction
    let catCollisionSound: SKAction = SKAction.playSoundFileNamed("hitCat.wav", waitForCompletion: false)
    let enemyCollisionSound: SKAction = SKAction.playSoundFileNamed("hitCatLady.wav", waitForCompletion: false)
    var invincible: Bool = false
    var lives = 3
    var gameOver = false

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

        let background = SKSpriteNode(imageNamed: "background1")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = -1
        addChild(background)

        zombie = SKSpriteNode(imageNamed: "zombie1")
        zombie.position = CGPoint(x:400, y:400)
        zombie.zPosition = 100
        addChild(zombie)
        
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(spawnEnemy),
            SKAction.waitForDuration(2)
            ])))
        
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(spawnCat),
            SKAction.waitForDuration(1)])))
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
        moveTrain()
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
        let bottomLeft = CGPoint(x: 0, y: CGRectGetMinY(playableRect))
        let topRight = CGPoint(x: size.width, y: CGRectGetMaxY(playableRect))

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
            x: CGFloat.random(min: CGRectGetMinX(playableRect),
                max: CGRectGetMaxX(playableRect)),
            y: CGFloat.random(min: CGRectGetMinY(playableRect),
                max: CGRectGetMaxY(playableRect)))
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
        enemy.position = CGPoint(x: size.width + enemy.size.width/2, y: size.height/2)
        enemy.position = CGPoint(x: size.width + enemy.size.width/2,
                                 y: CGFloat.random(min: CGRectGetMinY(playableRect) + enemy.size.height/2, max: CGRectGetMaxY(playableRect) - enemy.size.height/2)
        )
        enemy.name = "enemy"
        addChild(enemy)
        
        let actionMove = SKAction.moveTo(CGPoint(x:-enemy.size.width/2, y: enemy.position.y), duration: 2)
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
        
        if trainCount >= 6 && !gameOver {
            gameOver = true
            print("you win!")
            
            backgroundMusicPlayer.stop()
            let gameOverScene = GameOverScene(size: self.size, won: true)
            gameOverScene.scaleMode = self.scaleMode
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
    }
}
