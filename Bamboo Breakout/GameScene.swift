/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import SpriteKit
import GameplayKit

let BallCategoryName = "ball"
let PaddleCategoryName = "paddle"
let BlockCategoryName = "block"
let GameMessageName = "gameMessage"

let BallCategory: UInt32 = 0x1 << 0
let BottomCategory: UInt32 = 0x1 << 1
let BlockCategory: UInt32 = 0x1 << 2
let PaddleCategory: UInt32 = 0x1 << 3
let BorderCategory: UInt32 = 0x1 << 4

class GameScene: SKScene, SKPhysicsContactDelegate {

  // MARK: - Properties
  var isFingerOnPaddle = false
  let tapToPlayNextLevel = SKLabelNode(fontNamed: "Chalkduster")
  var nextLevel = 2
  let totalLevels = 6
  
  lazy var gameState: GKStateMachine = GKStateMachine(states: [
    WaitingForTap(scene: self),
    Playing(scene: self),
    LevelOver(scene: self),
    GameOver(scene: self)
  ])
  
  var gameWon : Bool = false {
    didSet {
      let gameOver = childNode(withName: GameMessageName) as! SKSpriteNode
      let textureName = gameWon ? "YouWon" : "GameOver"
      let texture = SKTexture(imageNamed: textureName)
      let actionSequence = SKAction.sequence([SKAction.setTexture(texture),
        SKAction.scale(to: 1.0, duration: 0.25)])
      
      gameOver.run(actionSequence)
      run(gameWon ? gameWonSound : gameOverSound)
    }
  }
  
  let blipSound = SKAction.playSoundFileNamed("pongblip", waitForCompletion: false)
  let blipPaddleSound = SKAction.playSoundFileNamed("paddleBlip", waitForCompletion: false)
  let bambooBreakSound = SKAction.playSoundFileNamed("BambooBreak", waitForCompletion: false)
  let gameWonSound = SKAction.playSoundFileNamed("game-won", waitForCompletion: false)
  let gameOverSound = SKAction.playSoundFileNamed("game-over", waitForCompletion: false)

  // MARK: - Overrides
  override func didMove(to view: SKView) {
    super.didMove(to: view)
    
    let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
    borderBody.friction = 0
    self.physicsBody = borderBody
    
    physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
    physicsWorld.contactDelegate = self
    
    let ball = childNode(withName: BallCategoryName) as! SKSpriteNode
    
    let bottomRect = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: 1)
    let bottom = SKNode()
    bottom.physicsBody = SKPhysicsBody(edgeLoopFrom: bottomRect)
    addChild(bottom)
    
    let paddle = childNode(withName: PaddleCategoryName) as! SKSpriteNode
    
    bottom.physicsBody!.categoryBitMask = BottomCategory
    ball.physicsBody!.categoryBitMask = BallCategory
    paddle.physicsBody!.categoryBitMask = PaddleCategory
    borderBody.categoryBitMask = BorderCategory
    
    ball.physicsBody!.contactTestBitMask = BottomCategory | BlockCategory | BorderCategory | PaddleCategory
    
    enumerateChildNodes(withName: "block", using: {
        node, stop in
        
        node.physicsBody = SKPhysicsBody(rectangleOf: node.frame.size)
        node.physicsBody!.allowsRotation = false
        node.physicsBody!.friction = 0.0
        node.physicsBody!.affectedByGravity = false
        node.physicsBody!.isDynamic = false
        node.name = BlockCategoryName
        node.physicsBody!.categoryBitMask = BlockCategory
        node.zPosition = 2
    })
    
    let gameMessage = SKSpriteNode(imageNamed: "TapToPlay")
    gameMessage.name = GameMessageName
    gameMessage.position = CGPoint(x: frame.midX, y: frame.midY)
    gameMessage.zPosition = 4
    gameMessage.setScale(0.0)
    addChild(gameMessage)
    
    let trailNode = SKNode()
    trailNode.zPosition = 1
    addChild(trailNode)
    let trail = SKEmitterNode(fileNamed: "BallTrail")!
    trail.targetNode = trailNode
    ball.addChild(trail)
    
    gameState.enter(WaitingForTap.self)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    switch gameState.currentState {
    case is WaitingForTap:
      gameState.enter(Playing.self)
      isFingerOnPaddle = true
      
    case is Playing:
      let touch = touches.first
      let touchLocation = touch!.location(in: self)
      
      if let body = physicsWorld.body(at: touchLocation) {
        if body.node!.name == PaddleCategoryName {
          isFingerOnPaddle = true
        }
      }
      
    case is LevelOver:
      
      ODRManager.shared.requestSceneWith(tag: "level\(nextLevel)", onSuccess: {
        guard let newScene = GameScene(fileNamed: "GameScene\(self.nextLevel)") else {
          return
        }
        
        newScene.scaleMode = .aspectFit
        newScene.nextLevel = self.nextLevel + 1
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        self.view?.presentScene(newScene, transition: reveal)
      }, onFailure: { (error) in
        let controller = UIAlertController(
          title: "Error",
          message: "There was a problem",
          preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: "Dismiss", style: .default))
        guard let rootViewController = self.view?.window?.rootViewController else {
          return
        }
        
        rootViewController.present(controller, animated: true)
      })
      
    case is GameOver:
      
      if let newScene = GameScene(fileNamed:"GameScene1") {
        
        newScene.scaleMode = .aspectFit
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        self.view?.presentScene(newScene, transition: reveal)
      }
      
    default:
      break
    }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    guard isFingerOnPaddle else { return }
      
    let touch = touches.first
    let touchLocation = touch!.location(in: self)
    let previousLocation = touch!.previousLocation(in: self)

    let paddle = childNode(withName: PaddleCategoryName) as! SKSpriteNode

    var paddleX = paddle.position.x + (touchLocation.x - previousLocation.x)

    paddleX = max(paddleX, paddle.size.width / 2)
    paddleX = min(paddleX, size.width - paddle.size.width / 2)

    paddle.position = CGPoint(x: paddleX, y: paddle.position.y)
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    isFingerOnPaddle = false
  }
  
  override func update(_ currentTime: TimeInterval) {
    gameState.update(deltaTime: currentTime)
  }
  
  func didBegin(_ contact: SKPhysicsContact) {
    guard gameState.currentState is Playing else { return }

    var firstBody: SKPhysicsBody
    var secondBody: SKPhysicsBody

    if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
      firstBody = contact.bodyA
      secondBody = contact.bodyB
    } else {
      firstBody = contact.bodyB
      secondBody = contact.bodyA
    }

    if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BottomCategory {
      gameState.enter(GameOver.self)
      gameWon = false
    }

    if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BlockCategory {
      breakBlock(secondBody.node!)
      if isGameWon() {
        gameState.enter(GameOver.self)
        gameWon = true
      }
      else if numberOfBlocksLeft() == 0 {

        let tapToPlayNextLevel = SKLabelNode(fontNamed: "Chalkduster")
        tapToPlayNextLevel.text = "TAP TO PLAY NEXT LEVEL"
        tapToPlayNextLevel.fontSize = 32
        tapToPlayNextLevel.fontColor = SKColor.white
        tapToPlayNextLevel.position = CGPoint(x: frame.midX, y: frame.midY)
        tapToPlayNextLevel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center

        addChild(tapToPlayNextLevel)

        gameState.enter(LevelOver.self)
      }
    }

    if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BorderCategory {
      run(blipSound)
    }


    if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == PaddleCategory {
      run(blipPaddleSound)
    }
  }

  func breakBlock(_ node: SKNode) {
    run(bambooBreakSound)
    let particles = SKEmitterNode(fileNamed: "BrokenPlatform")!
    particles.position = node.position
    particles.zPosition = 3
    addChild(particles)
    particles.run(SKAction.sequence([SKAction.wait(forDuration: 1.0), SKAction.removeFromParent()]))
    node.removeFromParent()
  }
  
  func randomFloat(from:CGFloat, to:CGFloat) -> CGFloat {
    let rand:CGFloat = CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    return (rand) * (to - from) + from
  }
  
  func numberOfBlocksLeft() -> Int {
    
    var numberOfBricks = 0
    self.enumerateChildNodes(withName: BlockCategoryName) {
      node, stop in
      numberOfBricks = numberOfBricks + 1
    }
    return numberOfBricks
  }
  
  func isGameWon() -> Bool {
    return numberOfBlocksLeft() == 0 && nextLevel + 1 == totalLevels
  }
}
