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

class Playing: GKState {

  // MARK: - Properties
  unowned let scene: GameScene

  // MARK: - Initializers
  init(scene: SKScene) {
    self.scene = scene as! GameScene
    super.init()
  }

  // MARK: - Overrides
  override func didEnter(from previousState: GKState?) {
    guard previousState is WaitingForTap,
      let ball = scene.childNode(withName: BallCategoryName) as? SKSpriteNode else {
        return
    }

    ball.physicsBody?.applyImpulse(CGVector(dx: randomDirection(), dy: randomDirection()))
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    guard let ball = scene.childNode(withName: BallCategoryName) as? SKSpriteNode,
      let physicsBody = ball.physicsBody else {
        return
    }

    let maxSpeed: CGFloat = 400.0
    
    let xSpeed = sqrt(physicsBody.velocity.dx * physicsBody.velocity.dx)
    let ySpeed = sqrt(physicsBody.velocity.dy * physicsBody.velocity.dy)
    
    let speed = sqrt(physicsBody.velocity.dx * physicsBody.velocity.dx + physicsBody.velocity.dy * physicsBody.velocity.dy)
    
    if xSpeed <= 10.0 {
      physicsBody.applyImpulse(CGVector(dx: randomDirection(), dy: 0.0))
    }
    if ySpeed <= 10.0 {
      physicsBody.applyImpulse(CGVector(dx: 0.0, dy: randomDirection()))
    }
    
    if speed > maxSpeed {
      physicsBody.linearDamping = 0.4
    } else {
      physicsBody.linearDamping = 0.0
    }
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    return stateClass is GameOver.Type || stateClass is LevelOver.Type
  }

  // MARK: - Internal
  func randomDirection() -> CGFloat {
    let speedFactor: CGFloat = 3.0
    if scene.randomFloat(from: 0.0, to: 100.0) >= 50 {
      return -speedFactor
    } else {
      return speedFactor
    }
  }
}
