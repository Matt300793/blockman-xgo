//
//  InsufficientBalanceViewController.swift
//  BlockyModes
//
//  Created by KiBen on 2018/3/8.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit

class InsufficientBalanceViewController: BaseViewController {
    
    fileprivate weak var containView: UIView?
    fileprivate weak var adsButton: UIButton?
    fileprivate weak var messageLabel: UILabel?
    fileprivate weak var seperator: UIView?
    fileprivate var adsManager: UnityVideoAdsManager!
    private var showAds = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func createAndLayoutChildViews() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        
        let cacheTimeInterval = BlockyUserDefaults.timeInterval(forKey: BlockyUserDefaults.dailyWatchVideoAdsTimeIntervalKey)
        showAds = params as! Bool && (cacheTimeInterval == 0 || Date().timeIntervalSince1970 - cacheTimeInterval > 3600)
        if showAds {
            adsManager = UnityVideoAdsManager(presentingController: self, delegate: self)
        }
        
        adsManager = UnityVideoAdsManager(presentingController: self, delegate: self)
        let containView = UIView().addTo(superView: view).configure { (view) in
            view.backgroundColor = R.color.appColor._fae7ca()
        }.layout { (make) in
            make.width.equalToSuperview().multipliedBy(0.8)
            make.center.equalToSuperview()
        }
        self.containView = containView
        
        let titleLabel = UILabel().addTo(superView: containView).configure { (label) in
            label.font = UIFont.size15
            label.textColor = R.color.appColor._333333()
            label.text = R.string.localizable.notification()
        }.layout { (make) in
            make.top.equalToSuperview().offset(25)
            make.centerX.equalToSuperview()
        }
        
        let messageLabel = UILabel().addTo(superView: containView).configure { (label) in
            label.font = UIFont.size15
            label.numberOfLines = 0
            label.textColor = R.color.appColor._666666()
            label.text = R.string.localizable.balance_not_enough_then_recharge()
            label.textAlignment = .center
        }.layout { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(29)
            make.width.equalToSuperview().multipliedBy(0.6)
            make.centerX.equalToSuperview()
        }
        self.messageLabel = messageLabel
        
        let firstSeperatorLine = UIView().addTo(superView: containView).configure { (view) in
            view.backgroundColor = R.color.appColor._e7c99e()
        }.layout { (make) in
            make.top.equalTo(messageLabel.snp.bottom).offset(30)
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        adsButton = UIButton().addTo(superView: containView).layout(snapKitMaker: { (make) in
            make.top.equalTo(firstSeperatorLine.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(showAds ? 45 : 0)
        }).configure({ (button) in
            button.isUserInteractionEnabled = false
            button.clipsToBounds = true
            button.setImage(R.image.daily_task_video_disable(), for: .normal)
        })
        if UnityVideoAdsManager.unityIsInitialized() {
            addRedDotInAdsButton()
        }
        adsButton!.rx.tap.subscribe(onNext: {[unowned self] in
            BlockyUserDefaults.storeTimeInterval(Date().timeIntervalSince1970, forKey: BlockyUserDefaults.dailyWatchVideoAdsTimeIntervalKey)
            self.adsManager.show()
        }).disposed(by: disposeBag)
        
        let secondSeperatorLine = UIView().addTo(superView: containView).configure { (view) in
            view.backgroundColor = R.color.appColor._e7c99e()
        }.layout { (make) in
            make.top.equalTo(adsButton!.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        self.seperator = secondSeperatorLine
        
        let verticalSeparator = UIView().addTo(superView: containView).configure { (vertical) in
            vertical.backgroundColor = R.color.appColor._e7c99e()
        }.layout { (make) in
            make.top.equalTo(secondSeperatorLine.snp.bottom)
            make.width.equalTo(1)
            make.height.equalTo(45)
            make.centerX.equalToSuperview()
        }
        
        let doneButton = UIButton().addTo(superView: containView).configure { (doneButton) in
            doneButton.titleLabel?.font = UIFont.size18
            doneButton.setTitleColor(R.color.appColor._0ab950(), for: .normal)
            doneButton.setTitle(NSLocalizedString("top_up", comment: ""), for: .normal)
        }.layout { (make) in
            make.left.equalTo(verticalSeparator.snp.right)
            make.top.height.equalTo(verticalSeparator)
            make.right.equalToSuperview()
        }
        doneButton.rx.tap.subscribe(onNext: {
            AppDelegate.globalServive().pushViewModel(RechargeViewModel.self, params: nil, animated: true)
        }).disposed(by: disposeBag)
        
        UIButton().addTo(superView: containView).configure { (cancelButton) in
            cancelButton.titleLabel?.font = UIFont.size15
            cancelButton.setTitleColor(R.color.appColor._666666(), for: .normal)
            cancelButton.setTitle(R.string.localizable.common_cancel(), for: .normal)
        }.layout { (make) in
            make.left.equalToSuperview()
            make.top.height.equalTo(verticalSeparator)
            make.right.equalTo(verticalSeparator.snp.left)
        }.rx.tap.subscribe(onNext: {
            AppDelegate.globalServive().dismissViewModel(animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        containView.layout { (make) in
            make.bottom.equalTo(doneButton.snp.bottom)
        }
    }
    
    fileprivate func getWatchAdsReward() {
        UserNetServer.signInDailyTask(type: 3).asObservable().subscribe(onNext: { (response) in
            let data = response["data"] as! [String : Any]
            let golds = data["golds"] as! Int
            AccountPropertyManager.shared.updateGolds(golds)
            BlockyAlert.show(title: R.string.localizable.notification(), message: R.string.localizable.common_receive_success())
        }, onError: { _ in
            BlockyHUD.showText(R.string.localizable.common_request_fail_retry(), inView: self.view, hideAfter: 1.5)
        }).disposed(by: disposeBag)
    }
    
    fileprivate func addRedDotInAdsButton() {
        guard showAds else { return }
        
        let dotLayer = CAShapeLayer()
        dotLayer.fillColor = UIColor.red.cgColor
        dotLayer.path = CGPath.init(roundedRect: CGRect(x: 0, y: 0, width: 5, height: 5), cornerWidth: 2.5, cornerHeight: 2.5, transform: nil)
        dotLayer.position = CGPoint(x: view.width * 0.8 * 0.5 + 15.0, y: 45 * 0.5 - 10.0)
        adsButton?.layer.addSublayer(dotLayer)
        adsButton?.isUserInteractionEnabled = true
    }
}

extension InsufficientBalanceViewController: UnityVideoAdsManagerDelegate {
    func adsReady(_ manager: UnityVideoAdsManager) {
        addRedDotInAdsButton()
    }
    
    func adsDidError(_ manager: UnityVideoAdsManager) {
        BlockyAlert.show(title: R.string.localizable.notification(), message: R.string.localizable.video_load_failed_close_retry())
    }
    
    func adsDidFinish(_ manager: UnityVideoAdsManager, with state: UnityVideoAdsManager.VideoAdsFinishState) {
        switch state {
        case .completed:
            getWatchAdsReward()
            adsButton?.isHidden = true
            seperator!.snp.remakeConstraints({ (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(messageLabel!.snp.bottom).offset(30)
                make.height.equalTo(1)
            })
            
        default:
            break
        }
    }
}
