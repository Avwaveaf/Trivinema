//
//  SceneDelegate.swift
//  Trivinema
//
//  Created by Afif Fadillah on 25/04/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene, willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.overrideUserInterfaceStyle = .dark
        window?.makeKeyAndVisible()
        
        // Set the splash screen as the root view controller immediately
        let splash = SplashViewController()
        window?.rootViewController = splash
    }
}

