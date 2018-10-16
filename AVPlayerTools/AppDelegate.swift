//
//  AppDelegate.swift
//  AVPlyerTools
//
//  Created by AndyCui on 2018/6/13.
//  Copyright © 2018年 AndyCuiYTT. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private var timer: Timer?
    private var timerCount: Int = 0
    private var bgTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        window?.makeKeyAndVisible()
        window?.rootViewController = SecondViewController()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
        // 这样做，可以在按home键进入后台后 ，播放一段时间，几分钟吧。但是不能持续播放网络歌曲，若需要持续播放网络歌曲，还需要申请后台任务id
        bgTask = application.beginBackgroundTask(expirationHandler: nil)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    @objc func timerAction() {
        timerCount = timerCount + 1
        if timerCount < 500 {
            return
        }
        timerCount = 0
        let newTask = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        if bgTask != UIBackgroundTaskIdentifier.invalid && newTask != UIBackgroundTaskIdentifier.invalid {
            UIApplication.shared.endBackgroundTask(convertToUIBackgroundTaskIdentifier(bgTask.rawValue))
            bgTask = newTask
        }
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
        timer?.invalidate()
        timer = nil
        timerCount = 0
        if bgTask != UIBackgroundTaskIdentifier.invalid {
            application.endBackgroundTask(convertToUIBackgroundTaskIdentifier(bgTask.rawValue))
            bgTask = UIBackgroundTaskIdentifier.invalid
        }
        
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }


}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIBackgroundTaskIdentifier(_ input: Int) -> UIBackgroundTaskIdentifier {
	return UIBackgroundTaskIdentifier(rawValue: input)
}
