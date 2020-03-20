//
//  AppDelegate.swift
//  CameraController
//
//  Created by Артём Зайцев on 18.03.2020.
//  Copyright © 2020 Артём Зайцев. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let vc = MediaCaptureViewController()
        let nvc = UINavigationController(rootViewController: vc)
        
        self.window?.rootViewController = nvc
        self.window?.makeKeyAndVisible()
        return true
    }
}

