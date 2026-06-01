//
//  AppDelegate.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2017/10/15.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private(set) var navigationStack: NavigationControllerStack?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        ThirdLogInManager.initializeSDK(application, didFinishLaunchingWithOptions: launchOptions)
        AppReviewConfigurator.startConfiguring()
        
        #if DEBUD
        #else
            AnalysisManager.start() // 开启统计
            AnalysisManager.trackEvent(AnalysisManager.Event.home_startapp)
        #endif
        
        let service = ViewModelService.init()
        navigationStack = NavigationControllerStack.init(viewModelService: service)
        
        window = UIWindow.init(frame: UIScreen.main.bounds)
        navigationStack?.service.resetRootViewModel(rootViewModel())
        window?.makeKeyAndVisible()

        #if DEBUG
//            _ = Observable<Int>.interval(1, scheduler: MainScheduler.instance).subscribe({ (num) in
//                print("Resource count \(RxSwift.Resources.total)")
//            })
        #endif
        
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return ThirdLogInManager.application(app, open: url, options: options)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        NetworkMonitor.shared.startMonitoring()
        FBSDKAppEvents.activateApp()
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension AppDelegate {
    static func delegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    static func globalServive() -> ViewModelService {
        return AppDelegate.delegate().navigationStack!.service
    }
    
    static func keyWindow() -> UIWindow {
        return AppDelegate.delegate().window!
    }
    
    static func currentNavigationController() -> UINavigationController {
        return AppDelegate.delegate().navigationStack!.topNavigationController()
    }
}

extension AppDelegate {
    fileprivate func rootViewModel() -> BaseViewModel.Type {
        return HomePageViewModel.self
    }
}
