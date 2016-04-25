//
//  GameViewController.swift
//  Tutorials
//
//  Created by Tony Cheng on 4/24/16.
//  Copyright (c) 2016 shilmista. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()


        let scene = GameScene(size:CGSize(width:2048, height:1536))
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .AspectFill
        skView.presentScene(scene)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
