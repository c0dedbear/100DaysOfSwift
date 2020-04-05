//
//  AppDelegate.swift
//  Project25-SelfieShare
//
//  Created by Mikhail Medvedev on 04.01.2020.
//  Copyright © 2020 Mikhail Medvedev. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
		window?.makeKeyAndVisible()
		return true
	}
}

