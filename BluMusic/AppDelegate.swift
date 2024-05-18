//
//  AppDelegate.swift
//  BluMusic
//
//  Created by Muhammad M. Munir on 18/05/24.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        if let window {
            window.rootViewController = MainTabBarController()
            window.makeKeyAndVisible()
        }
        return true
    }
}
