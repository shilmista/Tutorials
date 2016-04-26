//: Playground - noun: a place where people can play

import UIKit
import SpriteKit
import XCPlayground

let sceneView = SKView(frame: CGRect(x: 0, y: 0, width: 480, height: 320))

let scene = SKScene(size: CGSize(width: 480, height: 320))
scene.name = "My Scene"
sceneView.showsFPS = true
sceneView.showsPhysics = true
scene.physicsBody = SKPhysicsBody(edgeLoopFromRect: scene.frame)
scene.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
sceneView.presentScene(scene)

//XCPShowView("My Scene", view: sceneView)
XCPlaygroundPage.currentPage.liveView = sceneView

let square = SKSpriteNode(imageNamed: "square")
square.name = "shape"
square.position = CGPoint(x: scene.size.width * 0.25, y: scene.size.height * 0.5)

let circle = SKSpriteNode(imageNamed: "circle")
circle.name = "shape"
circle.position = CGPoint(x: scene.size.width * 0.5, y: scene.size.height * 0.5)

let triangle = SKSpriteNode(imageNamed: "triangle")
triangle.name = "shape"
triangle.position = CGPoint(x: scene.size.width * 0.75, y: scene.size.height * 0.5)

scene.addChild(square)
scene.addChild(circle)
scene.addChild(triangle)

square.physicsBody = SKPhysicsBody(rectangleOfSize: square.frame.size)

circle.physicsBody = SKPhysicsBody(circleOfRadius: circle.size.width/2)
circle.physicsBody?.dynamic = false

let circleLeft = SKAction.moveTo(CGPoint(x: 0 + circle.size.width/2, y: circle.position.y), duration: 1)
let circleRight = SKAction.moveTo(CGPoint(x: scene.frame.size.width - circle.size.width/2, y: circle.position.y), duration: 1)
let circleMove = SKAction.repeatActionForever(SKAction.sequence([circleLeft, circleRight]))
circle.runAction(circleMove)

var trianglePath = CGPathCreateMutable()
CGPathMoveToPoint(trianglePath, nil, -triangle.size.width/2, -triangle.size.height/2)
CGPathAddLineToPoint(trianglePath, nil, triangle.size.width/2, -triangle.size.height/2)
CGPathAddLineToPoint(trianglePath, nil, 0, triangle.size.height/2)
CGPathAddLineToPoint(trianglePath, nil, -triangle.size.width/2, -triangle.size.height/2)
triangle.physicsBody = SKPhysicsBody(polygonFromPath: trianglePath)

let l = SKSpriteNode(imageNamed: "L")
l.name = "shape"
l.position = CGPoint(x: scene.size.width * 0.5, y: scene.size.height * 0.75)
l.physicsBody = SKPhysicsBody(texture: l.texture!, size: l.size)
scene.addChild(l)

var blowingRight = true
var windForce = CGVector(dx: 50, dy: 0)

// 1
NSTimer.scheduledTimerWithTimeInterval(0.05, target: scene, selector:
    "windWithTimer:", userInfo: nil, repeats: true)
NSTimer.scheduledTimerWithTimeInterval(3.0, target: scene, selector:
    "switchWindDirection:", userInfo: nil, repeats: true)

extension SKScene {
    func windWithTimer(timer: NSTimer) {
        self.enumerateChildNodesWithName("sand") {
            node, _ in
            node.physicsBody!.applyForce(windForce)
        }
        self.enumerateChildNodesWithName("shape") {
            node, _ in
            node.physicsBody!.applyForce(windForce)
        }
    }
    
    func switchWindDirection(timer: NSTimer) {
        blowingRight = !blowingRight
        windForce = CGVector(dx: blowingRight ? 50 : -50, dy: windForce.dy)
    }
}

func spawnSand() {
    let sand = SKSpriteNode(imageNamed: "sand")
    sand.position = CGPoint(x: random(min: 0, max: scene.size.width), y: scene.size.height - sand.size.height)
    sand.physicsBody = SKPhysicsBody(circleOfRadius: sand.size.width/2)
    sand.name = "sand"
    sand.physicsBody!.restitution = 1.0
    sand.physicsBody!.density = 20
    scene.addChild(sand)
}

func shake() {
    scene.enumerateChildNodesWithName("sand") {
        node, _ in
        node.physicsBody!.applyImpulse(CGVector(dx: 0, dy: random(min: 20, max: 40)))
    }
    scene.enumerateChildNodesWithName("shape") {
        node, _ in
        node.physicsBody!.applyImpulse(CGVector(dx: random(min:20, max: 60), dy: random(min:20, max: 60)))
    }
    delay(seconds: 3, completion: shake)
}

delay(seconds: 2) { 
    scene.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
    scene.runAction(
        SKAction.repeatAction(
            SKAction.sequence([
                SKAction.runBlock(spawnSand),
                SKAction.waitForDuration(0.1)
                ])
            , count: 100)
    )
    delay(seconds: 12, completion: shake)
}