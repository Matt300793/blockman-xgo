//
//  NetworkMonitor.swift
//  BlockyModes
//
//  Created by KiBen on 2017/12/28.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation
import Alamofire

struct NetworkMonitor {
    // shared instance
    static let shared = NetworkMonitor()
    
    private let monitor = NetworkReachabilityManager()
    
    public func startMonitoring() {
        
        monitor?.listener = { status in
            switch status {
            case .unknown:
                fallthrough
            case .notReachable:
                BlockyHUD.showText(NSLocalizedString("network_lost_please_check", comment: "当前网络不可用，请检查网络"), inView: AppDelegate.keyWindow())
            case .reachable(.ethernetOrWiFi):
                fallthrough
            case .reachable(.wwan):
                AppUpdateManager.shared.check() // 检查版本
            }
        }
        monitor?.startListening()
    }
}
