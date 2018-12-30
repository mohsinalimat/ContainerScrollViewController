//
//  AppDelegate.swift
//  CodeExample
//
//  Created by Drew Olbrich on 12/29/18.
//  Copyright © 2018 Drew Olbrich. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window

        let codeSignUpViewController = CodeSignUpViewController()
        window.rootViewController = codeSignUpViewController
        window.makeKeyAndVisible()

        return true
    }

}
