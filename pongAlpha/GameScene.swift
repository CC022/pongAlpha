//
//  GameScene.swift
//  pongAlpha
//
//  Created by zzc on 10/27/18.
//  Copyright © 2018 zzc. All rights reserved.
//

import SpriteKit
import GameplayKit
import ARKit

class GameScene: SKScene, ARSessionDelegate {
    var LookAtPointX: Float = 0.0
    var LookAtPointZ: Float = 0.0
    var myARSession = ARSession()
    
    // What: Pong game model
    
    // Where: https://github.com/Archetapp/Pong
    
    // Why: Pong is a classic game that has been remastered many times. Referencing existing pong game model will allow the project to be focus on the interaction part
    var ball = SKSpriteNode()
    var computer = SKSpriteNode()
    var player0 = SKSpriteNode()
    var player0ScoreLabel = SKLabelNode()
    var computerScoreLabel = SKLabelNode()
    var XLabel = SKLabelNode()
    var YLabel = SKLabelNode()
    
    var player0Score = 0
    var computerScore = 0
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    override func didMove(to view: SKView) {
        myARSession.delegate = self
        myARSession.run(ARFaceTrackingConfiguration())
        

        ball = self.childNode(withName: "ball") as! SKSpriteNode
        computer = self.childNode(withName: "computer") as! SKSpriteNode
        player0 = self.childNode(withName: "player0") as! SKSpriteNode
        player0ScoreLabel = self.childNode(withName: "player0ScoreLabel") as! SKLabelNode
        computerScoreLabel = self.childNode(withName: "computerScoreLabel") as! SKLabelNode
        XLabel = self.childNode(withName: "XLabel") as! SKLabelNode
        YLabel = self.childNode(withName: "YLabel") as! SKLabelNode
        
        ball.zPosition = 0.5
        
        resetGame()
        serveBall()
        
        player0ScoreLabel.text = "\(player0Score)"
        computerScoreLabel.text = "\(computerScore)"
        
        let border = SKPhysicsBody(edgeLoopFrom: self.frame)
        border.friction = 0
        border.restitution = 1
        self.physicsBody = border
    }
    
    func resetGame() {
        player0Score = 0
        computerScore = 0
    }

    func serveBall() {
        player0ScoreLabel.text = "\(player0Score)"
        computerScoreLabel.text = "\(computerScore)"
        ball.texture = SKTexture(image: "😀".image()!)
        ball.position = CGPoint(x: 0, y: 0)
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        ball.physicsBody?.applyImpulse(CGVector(dx: 50, dy: 50))
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        computer.run(SKAction.moveTo(x: ball.position.x, duration: 0.2))
        player0.run(SKAction.moveTo(x: getLookPosition(), duration: 0.5))
        if ball.position.y < player0.position.y - player0.size.height * 2 {
            computerScore += 1
            serveBall()
        } else if ball.position.y > computer.position.y + computer.size.height * 2 {
            player0Score += 1
            serveBall()
        }
    }
    
}

extension GameScene {
    func getLookPosition() -> CGFloat {
        return (LookAtPointX > 0) ? self.frame.maxX : self.frame.minX
    }
    
//    func getLookPosition() -> CGFloat {
//        let leftMostTheta: CGFloat = 0.1
//        let rightMostTheta: CGFloat = -0.1
//        let minX = self.frame.minX
//        let maxX = self.frame.maxX
//        let theta = CGFloat(atan(LookAtPointX / LookAtPointZ))
//        var positionInScene = (minX - maxX) / (rightMostTheta - leftMostTheta) * theta
//        positionInScene = (positionInScene > maxX) ? maxX : positionInScene
//        positionInScene = (positionInScene < minX) ? minX : positionInScene
//        return positionInScene
//    }
    
    
//    func convertLookPoint(ToScenePosition point: Float) -> CGFloat {
//        let leftMostPoint: CGFloat = 0.1
//        let rightMostPoint: CGFloat = -0.1
//        let minX = self.frame.minX
//        let maxX = self.frame.maxX
//        var positionInScene = (minX - maxX) / (rightMostPoint - leftMostPoint) * CGFloat(point)
//        positionInScene = (positionInScene > maxX) ? maxX : positionInScene
//        positionInScene = (positionInScene < minX) ? minX : positionInScene
//        return positionInScene
//    }
    
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        let faceAnchor = anchors.first as? ARFaceAnchor
        print("\(faceAnchor?.transform.debugDescription)")
        LookAtPointX = Float(faceAnchor!.lookAtPoint.x)
        LookAtPointZ = Float(faceAnchor!.lookAtPoint.z)
        XLabel.text = String(format:"%.4f",faceAnchor!.lookAtPoint.x)
        YLabel.text = String(format:"%.4f",faceAnchor!.lookAtPoint.y)
    }
    
}



// What: emoji to UIImage

// Where: https://stackoverflow.com/questions/38809425/convert-apple-emoji-string-to-uiimage

// Why: The convertion from emoji to UIImage is not provided in offical API, and these steps are not related to the interaction part of this project

extension String {
    func image() -> UIImage? {
        let size = CGSize(width: 70, height: 70)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let rect = CGRect(origin: .zero, size: size)
        (self as AnyObject).draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: 60)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}


