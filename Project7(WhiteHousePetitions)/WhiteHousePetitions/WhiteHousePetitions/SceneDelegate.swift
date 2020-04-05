//
//  SceneDelegate.swift
//  WhiteHousePetitions
//
//  Created by Mikhail Medvedev on 27.10.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let tabBarController = window?.rootViewController as? UITabBarController {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
           let mostVotedVC = storyBoard.instantiateViewController(identifier: "NavController")
            mostVotedVC.tabBarItem = UITabBarItem(tabBarSystemItem: .mostViewed, tag: 1)
            tabBarController.viewControllers?.append(mostVotedVC)
        }
    }
}

