//
//  GameScene.swift
//  ShootGame
//
//  Created by supermacho on 11.09.17.
//  Copyright © 2017 student. All rights reserved.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let Enemy :UInt32 = 0x1 << 0
    static let SmallBall :UInt32 = 0x1 << 1
    static let MainBall :UInt32 = 0x1 << 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var MainBall = SKSpriteNode(imageNamed: "Ball")
    
    var enemyTimer = Timer()
    
    var hits = 0
    var gameStarted = false
    
    var TTBLbl = SKLabelNode(fontNamed: "STHeitiJ-Medium")
    var scoreLbl = SKLabelNode(fontNamed: "STHeitiJ-Medium")
    var highScoreLbl = SKLabelNode(fontNamed: "STHeitiJ-Medium")
    
    
    var FadingAnim = SKAction()
    
    var Score = 0
    var HightScore = 0
    override func didMove(to view: SKView) {
        
        // Get label node from scene and store it for use later
        self.physicsWorld.contactDelegate = self
        let highScoreDef = UserDefaults.standard
        if highScoreDef.value(forKey: "HightScore") != nil {
            HightScore = highScoreDef.value(forKey: "HightScore") as! Int
            highScoreLbl.text = "HightScore : \(HightScore)"
        }
        TTBLbl.text = "Tap to begin"
        TTBLbl.fontSize = 34
        TTBLbl.position = CGPoint(x: (scene?.frame.width)! / 2, y: (scene?.frame.height)! / 2)
        TTBLbl.fontColor = UIColor.white
        TTBLbl.zPosition = 2.0
        addChild(TTBLbl)
        
        FadingAnim = SKAction.sequence([SKAction.fadeIn(withDuration: 1.0), SKAction.fadeOut(withDuration: 1.0)])
        TTBLbl.run(SKAction.repeatForever(FadingAnim))
        
        highScoreLbl.text = "HighScore : \(HightScore)"
        highScoreLbl.position = CGPoint(x: (scene?.frame.width)! / 2, y: (scene?.frame.height)! / 1.3)
        highScoreLbl.fontColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        self.addChild(highScoreLbl)
        
        scoreLbl.alpha = 0
        scoreLbl.fontSize = 35
        scoreLbl.position = CGPoint(x: (scene?.frame.width)! / 2, y: (scene?.frame.height)! / 1.3)
        scoreLbl.fontColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        scoreLbl.text = "\(Score)"
        self.addChild(scoreLbl)
        
        
        
        
        
        backgroundColor = UIColor.white
        MainBall.size = CGSize(width: 325, height: 325)
        MainBall.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        MainBall.color = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        MainBall.colorBlendFactor = 1.0
        MainBall.zPosition = 1.0
        MainBall.physicsBody = SKPhysicsBody(circleOfRadius: MainBall.size.width / 2)
        MainBall.physicsBody?.categoryBitMask = PhysicsCategory.MainBall
        MainBall.physicsBody?.collisionBitMask = PhysicsCategory.Enemy
        MainBall.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
        MainBall.physicsBody?.affectedByGravity = false
        MainBall.physicsBody?.isDynamic = false
        MainBall.name = "MainBall"
        
        self.addChild(MainBall)
        
        
        
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node != nil && contact.bodyB.node != nil {
            
        
            let firstBody = contact.bodyA.node as! SKSpriteNode
            let secondBody = contact.bodyB.node as! SKSpriteNode
            
            if ((firstBody.name == "Enemy") && (secondBody.name == "SmallBall")) {
                collisionBullet(Enemy: firstBody, SmallBall: secondBody)
            }else if ((firstBody.name == "SmallBall") && (secondBody.name == "Enemy")) {
                collisionBullet(Enemy: secondBody, SmallBall: firstBody)
            }
            else if ((firstBody.name == "MainBall") && (secondBody.name == "Enemy")) {
                
                collisionMain(Enemy: secondBody)
            
            }else if ((firstBody.name == "Enemy") && (secondBody.name == "MainBall")) {
                collisionMain(Enemy: firstBody)
            }
        }
    }
    
    func collisionMain(Enemy: SKSpriteNode) {
        if hits < 2 {
            MainBall.run(SKAction.scale(by: 1.5, duration: 0.4))
            Enemy.physicsBody?.affectedByGravity = true
            Enemy.removeAllActions()
            
            MainBall.run(SKAction.sequence([SKAction.colorize(with: UIColor.red, colorBlendFactor: 1.0, duration: 0.1), SKAction.colorize(with: SKColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0), colorBlendFactor: 1.0, duration: 0.1)]))
            
            hits += 1
            
            Enemy.removeFromParent()
        }else {
            Enemy.removeFromParent()
            enemyTimer.invalidate()
            gameStarted = false
            scoreLbl.run(SKAction.fadeOut(withDuration: 0.2))
            TTBLbl.run(SKAction.fadeIn(withDuration: 1.0))
            TTBLbl.run(SKAction.repeatForever(FadingAnim))
            highScoreLbl.run(SKAction.fadeIn(withDuration: 0.2))
            
            if Score > HightScore {
               let highScoreDef = UserDefaults.standard
                HightScore = Score
                highScoreDef.set(HightScore, forKey: "HightScore")
                highScoreLbl.text = "HightScore : \(HightScore)"
            }
            
        }
        
    }
    
    
    func collisionBullet(Enemy: SKSpriteNode, SmallBall: SKSpriteNode) {
        Enemy.physicsBody?.isDynamic = true
        Enemy.physicsBody?.affectedByGravity = true
        Enemy.physicsBody?.mass = 5.0
        SmallBall.physicsBody?.mass = 5.0
        Enemy.removeAllActions()
        SmallBall.removeAllActions()
        
        Enemy.physicsBody?.contactTestBitMask = 0
        Enemy.physicsBody?.collisionBitMask = 0
        Enemy.name = nil
        Score += 1
        scoreLbl.text = "\(Score)"

        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gameStarted == false {
            enemyTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(GameScene.enemies), userInfo: nil, repeats: true)
            gameStarted = true
            MainBall.run(SKAction.scale(to: 0.6, duration: 0.2 ))
            hits = 0
            
            TTBLbl.removeAllActions()
            TTBLbl.run(SKAction.fadeOut(withDuration: 0.2))
            highScoreLbl.run(SKAction.fadeOut(withDuration: 0.2))
            scoreLbl.run(SKAction.sequence([SKAction.wait(forDuration: 1.0), SKAction.fadeIn(withDuration: 1.0)]))
            
            
            Score = 0
            scoreLbl.text = "\(Score)"
            
            
        }else {
            
        
        for touch in (touches ) {
            let location = touch.location(in: self)
            
            let smallBall = SKSpriteNode(imageNamed: "Ball")
            smallBall.zPosition = -1.0
            smallBall.position = MainBall.position
            smallBall.size = CGSize(width: 30, height: 30)
            smallBall.physicsBody = SKPhysicsBody(circleOfRadius: smallBall.size.width / 2)
           // smallBall.physicsBody?.affectedByGravity = false
            smallBall.color = UIColor(red: 0.1, green: 0.85, blue: 0.95, alpha: 1.0)
            smallBall.colorBlendFactor = 1.0
            smallBall.physicsBody?.categoryBitMask = PhysicsCategory.SmallBall
            smallBall.physicsBody?.collisionBitMask = PhysicsCategory.Enemy
            smallBall.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
            smallBall.name = "SmallBall"
            
            smallBall.physicsBody?.isDynamic = true
            smallBall.physicsBody?.affectedByGravity = true
            
            
            var dx = CGFloat(location.x - MainBall.position.x)
            var dy = CGFloat(location.y - MainBall.position.y)
            
            let magnitude = sqrt(dx * dx + dy * dy)
            
            dx /= magnitude
            dy /= magnitude
            self.addChild(smallBall)
            let vector = CGVector(dx: 16.0 * dx, dy: 16.0 * dy)
            smallBall.physicsBody?.applyImpulse(vector)
            
            }
        }
    }
    
    
    func enemies() {
        let enemy = SKSpriteNode(imageNamed: "Ball")
        enemy.size = CGSize(width: 30, height: 30)
        enemy.color = UIColor(red: 0.9, green: 0.1, blue: 0.1, alpha: 1.0)
        enemy.colorBlendFactor = 1.0
        
        
        //Physics
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: enemy.size.width / 2)
        enemy.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        enemy.physicsBody?.contactTestBitMask = PhysicsCategory.SmallBall | PhysicsCategory.MainBall
        enemy.physicsBody?.collisionBitMask = PhysicsCategory.SmallBall | PhysicsCategory.MainBall
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.isDynamic = true
        enemy.name = "Enemy"
        
        
        let randomPosNmbr = arc4random() % 4
        
        switch randomPosNmbr {
        case 0:
            enemy.position.x = 0
            
            let positionY = arc4random_uniform(UInt32(frame.size.height))
            enemy.position.y = CGFloat(positionY)
            self.addChild(enemy)
            break
        case 1:
            enemy.position.y = 0
            
            let positionX = arc4random_uniform(UInt32(frame.size.width))
            enemy.position.x = CGFloat(positionX)
            self.addChild(enemy)
            break
        case 2:
            enemy.position.y = frame.size.height
            
            let positionX = arc4random_uniform(UInt32(frame.size.width))
            enemy.position.x = CGFloat(positionX)
            self.addChild(enemy)
            break
        case 3:
            enemy.position.x = frame.size.width
            
            let positionY = arc4random_uniform(UInt32(frame.size.height))
            enemy.position.y = CGFloat(positionY)
            self.addChild(enemy)
            break
        default:
            break
        }
        
        enemy.run(SKAction.move(to: MainBall.position, duration: 3))
        
        
    }
        
         
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
