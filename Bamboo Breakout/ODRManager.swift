//
//  ODRManager.swift
//  Bamboo Breakout
//
//  Created by icung on 19/10/21.
//  Copyright © 2021 Razeware LLC. All rights reserved.
//

import Foundation

class ODRManager {
  
  // Mark: - Properties
  static let shared = ODRManager()
  var currentRequest: NSBundleResourceRequest?
  
  func requestSceneWith(tag: String, onSuccess: @escaping () -> Void, onFailure: @escaping (NSError) -> Void) {
    currentRequest = NSBundleResourceRequest(tags: [tag])
    
    guard let requset = currentRequest else {
      return
    }
    
    requset.loadingPriority = NSBundleResourceRequestLoadingPriorityUrgent
    requset.beginAccessingResources { (error: Error?) in
      if let error = error {
        onFailure(error as NSError)
        return
      }
      
      onSuccess()
    }
  }
}
