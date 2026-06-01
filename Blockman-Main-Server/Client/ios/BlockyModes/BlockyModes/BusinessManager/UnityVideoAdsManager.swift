//
//  UnityVideoAdsManager.swift
//  BlockyModes
//
//  Created by KiBen on 2018/3/8.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import Foundation

protocol UnityVideoAdsManagerDelegate: class {
    func adsReady(_ manager: UnityVideoAdsManager)
    func adsDidStart(_ manager: UnityVideoAdsManager)
    func adsDidError(_ manager: UnityVideoAdsManager)
    func adsDidFinish(_ manager: UnityVideoAdsManager, with state: UnityVideoAdsManager.VideoAdsFinishState)
}

extension UnityVideoAdsManagerDelegate {
    func adsDidStart(_ manager: UnityVideoAdsManager) { }
    func adsDidError(_ manager: UnityVideoAdsManager) { }
}

class UnityVideoAdsManager: NSObject {
    
    enum VideoAdsFinishState {
        case completed
        case skipped
        case error
    }
    
    public weak var delegate: UnityVideoAdsManagerDelegate?
    
    private weak var presentingViewController: UIViewController!
    fileprivate let rewardedPlacement = "rewardedVideo"
    
    init(presentingController: UIViewController, delegate: UnityVideoAdsManagerDelegate?) {
        super.init()
        
        self.delegate = delegate
        presentingViewController = presentingController
        
        if !UnityAds.isInitialized() {
            UnityAds.initialize("1726198", delegate: self)
        }else {
            UnityAds.setDelegate(self)
        }
    }
    
    static public func unityIsInitialized() -> Bool {
        return UnityAds.isInitialized()
    }
    
    public func show() {
        // 观看视频广告
        if UnityAds.isReady(rewardedPlacement) {
            UnityAds.show(presentingViewController, placementId: rewardedPlacement)
        }
    }
}

extension UnityVideoAdsManager: UnityAdsDelegate {
    func unityAdsReady(_ placementId: String) {
        DebugLog("unityAdsReady: \(placementId)")
        delegate?.adsReady(self)
    }
    
    func unityAdsDidStart(_ placementId: String) {
        DebugLog("unityAdsDidStart: \(placementId)")
        delegate?.adsDidStart(self)
    }
    
    func unityAdsDidError(_ error: UnityAdsError, withMessage message: String) {
        delegate?.adsDidError(self)
        BlockyAlert.show(title: R.string.localizable.notification(), message: "视频加载失败，请关闭重试")
    }
    
    func unityAdsDidFinish(_ placementId: String, with state: UnityAdsFinishState) {
        switch state {
        case .completed:
            delegate?.adsDidFinish(self, with: .completed)
        case .skipped:
            delegate?.adsDidFinish(self, with: .skipped)
        case .error:
            delegate?.adsDidFinish(self, with: .error)
        }
    }
}
