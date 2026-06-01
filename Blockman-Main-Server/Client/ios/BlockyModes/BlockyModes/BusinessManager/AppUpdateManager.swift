//
//  AppUpdateManager.swift
//  BlockyModes
//
//  Created by KiBen on 2017/12/28.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class AppUpdateManager {
    
    static let shared = AppUpdateManager()
    
    private let disposeBag = DisposeBag()
    private var appVersionForItunes = ""
    
    func check() {
        for subView in AppDelegate.keyWindow().subviews.reversed() {
            if subView is AppUpdateAlertView { return }
        }
        
        // 从iTunes获取APP版本信息
        ConfigurationNetServer.checkAppUpdate().map { [unowned self] appInfoForItunes -> Bool in
            let results = appInfoForItunes["results"] as! [[String : Any]]
            guard !results.isEmpty else {
                return false
            }
            self.appVersionForItunes = results.first!["version"] as! String
            return AppInfo.currentShortVersion < self.appVersionForItunes
            }.asDriver(onErrorJustReturn: false)
            .filter { // 过滤，如果是最新版本，不做任何操作
                $0
            }.flatMap({ _ in
                // 从后台获取更新内容
                ConfigurationNetServer.fetchAppUpdateInfo().mapModel(type: AppUpdateModel.self).map({ model -> AppUpdateModel? in
                    model
                }).asDriver(onErrorJustReturn: nil)
                
            }).map({ appupdateModel -> (String, String, String?, Bool)? in
                guard let appupdateModel = appupdateModel else {
                    return nil
                }
                
                guard self.appVersionForItunes == appupdateModel.version! else {return nil}
                
                // 处理数据
                let updateContent = (appupdateModel.updateContent![Locale.current.identifier] ?? appupdateModel.updateContent!["en_US"])!
                let thumbnailURLString = appupdateModel.thumbnailURL
                let downloadURLString = appupdateModel.downloadURL!
                if appupdateModel.isForceUpdate! {
                    return  (updateContent, downloadURLString, thumbnailURLString, true)
                }
                
                if AppInfo.currentShortVersion < appupdateModel.minAvailableVersion! { // 比最低允许的版本还小
                    return  (updateContent, downloadURLString, thumbnailURLString, true)
                }
                
                guard appupdateModel.needToForceUpdateVersions!.contains(AppInfo.currentShortVersion) else {
                    return (updateContent, downloadURLString, thumbnailURLString, false)
                }
                return (updateContent, downloadURLString, thumbnailURLString, true)
                
            }) .drive(onNext: { updateInfo in
                
                guard let (updateContent, downloadURLString, thumbnailURLString, forceUpdate) = updateInfo else {
                    return
                }
                
                // 强更
                if forceUpdate {
                    AppUpdateAlertView.init(updateContent: updateContent, downloadURLString: downloadURLString, thumbnailURLString: thumbnailURLString, forceUpdate: forceUpdate).addTo(superView: AppDelegate.keyWindow()).layout(snapKitMaker: { (make) in
                        make.edges.equalToSuperview()
                    })
                    BlockyUserDefaults.storeTimeInterval(Date().timeIntervalSince1970, forKey: BlockyUserDefaults.appUpdateTimeintervalKey)
                    return
                }
                
                // 不是强更，如果距离上次弹提示不足2天，则不弹提示
                let currentTimeinterval = Date().timeIntervalSince1970
                let cacheTimeinterval = BlockyUserDefaults.timeInterval(forKey: BlockyUserDefaults.appUpdateTimeintervalKey)
                let diffDays = (Int64)(currentTimeinterval - cacheTimeinterval) / 3600 * 24
                guard diffDays > 2 else { return }
                
                BlockyUserDefaults.storeTimeInterval(Date().timeIntervalSince1970, forKey: BlockyUserDefaults.appUpdateTimeintervalKey)
                AppUpdateAlertView.init(updateContent: updateContent, downloadURLString: downloadURLString, thumbnailURLString: thumbnailURLString, forceUpdate: forceUpdate).addTo(superView: AppDelegate.keyWindow()).layout(snapKitMaker: { (make) in
                    make.edges.equalToSuperview()
                })
                
            }).disposed(by: disposeBag)
    }
}
