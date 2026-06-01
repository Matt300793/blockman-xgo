//
//  AppReviewManager.swift
//  BlockyModes
//
//  Created by KiBen on 2018/2/28.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import Foundation
import RxSwift

struct AppReviewConfigurator {
    private static let disposeBag = DisposeBag()
    private static var ip = "http://ios.game.sandboxol.com:9902"
    
    public static var gameEngineIP: String {
        get {
            return ip
        }
    }
    
    public static func startConfiguring() {
        ConfigurationNetServer.checkAppUpdate().map { appInfoForItunes -> Bool in
            let results = appInfoForItunes["results"] as! [[String : Any]]
            guard !results.isEmpty else {
                return false
            }
            let appVersionForItunes = results.first!["version"] as! String
            return AppInfo.currentShortVersion <= appVersionForItunes
        }
        .asDriver(onErrorJustReturn: false)
        .filter { // 过滤，如果是最新版本，不做任何操作
            $0
        }
        .drive(onNext: { _ in
            AppReviewConfigurator.ip = "http://v3.game.sandboxol.com:9902"
        })
        .disposed(by: AppReviewConfigurator.disposeBag)
    }
}
