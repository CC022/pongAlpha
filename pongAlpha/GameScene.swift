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
import SceneKit

class GameScene: SKScene, ARSessionDelegate, SKButtonDelegate {
    var headRotation: Float = 0.0
    var myARSession = ARSession()
    
    // What: Pong game model
    
    // Where: https://github.com/Archetapp/Pong
    
    // Why: Pong is a classic game that has been remastered many times. Referencing existing pong game model will allow the project to be focus on the interaction part
    var resetButton = SKButton()
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
        let myARConfiguration = ARFaceTrackingConfiguration()
        myARConfiguration.worldAlignment = .camera
        myARSession.run(myARConfiguration, options: [.resetTracking, .removeExistingAnchors])
        
        resetButton = self.childNode(withName: "resetButton") as! SKButton
        resetButton.delegate = self
        resetButton.isUserInteractionEnabled = true
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
        let xx = Int(arc4random_uniform(20))
        let yy = Int(arc4random_uniform(10))
        let zz = Int(arc4random_uniform(4))
        var LorR = 1
        if zz > 2{
            LorR = 1
        }
        else{
            LorR = -1
        }
        ball.physicsBody?.applyImpulse(CGVector(dx:LorR*(xx+30), dy: yy+35))
        //ball.physicsBody?.applyImpulse(CGVector(dx: 45, dy: 45))
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        computer.run(SKAction.moveTo(x: ball.position.x, duration: 0.23))
        player0.run(SKAction.moveTo(x: getLookPosition(), duration: 0))
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
        let leftMostPoint: CGFloat = 0.2
        let rightMostPoint: CGFloat = -0.2
        let minX = self.frame.minX
        let maxX = self.frame.maxX
        var positionInScene = (minX - maxX) / (rightMostPoint - leftMostPoint) * CGFloat(headRotation)
        positionInScene = (positionInScene > maxX) ? maxX : positionInScene
        positionInScene = (positionInScene < minX) ? minX : positionInScene
        return positionInScene
    }
    
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        
        let faceAnchor = anchors.first as? ARFaceAnchor
        let faceT = faceAnchor?.transform
        getFaceRotateAngle(from: faceT!)
        
    }
    
    func getFaceRotateAngle(from faceTransform: simd_float4x4) {
        let unitZEnd = simd_float4([0, 0, 1, 1])
        let unitZStart = simd_float4([0, 0, 0, 1])
        let faceStart = faceTransform * unitZStart
        let faceEnd = faceTransform * unitZEnd
        let facingVector = faceEnd //- faceStart
        var faceSCNNode = SCNNode()
        faceSCNNode.simdTransform = faceTransform
        headRotation = faceSCNNode.eulerAngles.y
    }
    
    
    func touchUpInsideSKButton(sender: SKButton) {
        resetGame()
        let myARConfiguration = ARFaceTrackingConfiguration()
        myARConfiguration.worldAlignment = .camera
        myARSession.run(myARConfiguration, options: [.resetTracking, .removeExistingAnchors])
        serveBall()
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


