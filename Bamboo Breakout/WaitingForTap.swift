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

class WaitingForTap: GKState {

  // MARK: - Properties
  unowned let scene: GameScene

  // MARK: - Initializers
  init(scene: SKScene) {
    self.scene = scene as! GameScene
    super.init()
  }

  // MARK: - Overrides
  override func didEnter(from previousState: GKState?) {
    let scale = SKAction.scale(to: 1.0, duration: 0.25)
    scene.childNode(withName: GameMessageName)?.run(scale)
  }
  
  override func willExit(to nextState: GKState) {
    guard nextState is Playing else { return }

    let scale = SKAction.scale(to: 0, duration: 0.4)
    scene.childNode(withName: GameMessageName)?.run(scale)
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    return stateClass is Playing.Type
  }
}
