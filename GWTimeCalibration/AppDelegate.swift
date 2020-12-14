//
//  AppDelegate.swift
//  GWTimeCalibration
//
//  Created by huangwei on 2020/12/13.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GWTimeCalibrationManager.shared().startTimer()
        return true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        GWTimeCalibrationManager.shared().getServerTime(completeClosure: nil, failClosure: nil)
    }
}

