//
//  SceneDelegate.swift
//  Questomania
//
//  Created by National Team on 19.11.2022.
//

import UIKit
import SwiftUI

var pushViewToNavigation: ((_ view: any View) -> Void) = { _ in }
var shareFile: ((_ url: URL) -> Void) = { _ in }
var selectFile: (() -> Void) = {}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?


  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let scene = (scene as? UIWindowScene) else { return }
    
    let window = UIWindow(windowScene: scene)
    let navigationView = NavigationView()
    window.rootViewController = navigationView
    window.makeKeyAndVisible()
    
    self.window = window
    
    navigationView.push(view: MainView())
    
    pushViewToNavigation = { view in
      navigationView.push(view: view)
    }
    
    shareFile = { url in
      let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
      navigationView.present(activityVC, animated: true)
    }
    
    selectFile = {
      let docVC = UIDocumentPickerViewController(forOpeningContentTypes: [.data])
      docVC.delegate = self
      navigationView.present(docVC, animated: true)
    }
  }

  func sceneDidDisconnect(_ scene: UIScene) {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
  }

  func sceneDidBecomeActive(_ scene: UIScene) {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
  }

  func sceneWillResignActive(_ scene: UIScene) {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
  }

  func sceneWillEnterForeground(_ scene: UIScene) {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
  }

  func sceneDidEnterBackground(_ scene: UIScene) {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
  }


}

extension SceneDelegate: UIDocumentPickerDelegate,UINavigationControllerDelegate {
  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    guard let url = urls.first else { return }
    guard let data = try? Data(contentsOf: url) else { return }
    guard let quest = try? JSONDecoder().decode(QuestStepNode.self, from: data) else { return }
    
    guard let data = try? JSONEncoder().encode(quest) else { return }
    
    let path = FileManager.default.urls(for: .documentDirectory,
                                        in: .userDomainMask)[0].appendingPathComponent(url.lastPathComponent)
    try? data.write(to: path)
    
    pushViewToNavigation(PlayerView(questStep: quest))
  }
}
