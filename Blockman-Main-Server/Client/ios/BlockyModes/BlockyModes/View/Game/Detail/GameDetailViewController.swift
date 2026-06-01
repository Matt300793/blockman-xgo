//
//  GameDetailViewController.swift
//  BlockyModes
//
//  Created by KiBen on 2017/11/3.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import BlockModsGameKit

class GameDetailViewController: BaseViewController {
    
    override var inputType: ViewToViewModelInput.Type? {return GameDetailInput.self}
    
    private weak var basicInfoView: GameBasicInfoView?
    private weak var introductionView: GameIntroductionView?
    private weak var gameJoinView: UIView?
    fileprivate var enterGameButton: UIButton?
    fileprivate let enterGamePublish = PublishSubject<String>()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AnalysisManager.trackEvent(AnalysisManager.Event.home_game, parameters: ["gameID" : (params as? String) ?? ""])
        DecorationControllerManager.shared.destory()
    }
    
    override func createAndLayoutChildViews() {
        super.createAndLayoutChildViews()
        
        let scrollView = UIScrollView().addTo(superView: view).layout { (make) in
            make.edges.equalToSuperview()
            }.configure { (scrollView) in
                if #available(iOS 11.0, *) {
                    scrollView.contentInsetAdjustmentBehavior = .never
                }
        }
        
        let containView = UIView().addTo(superView: scrollView).layout {[unowned self] (make) in
            make.edges.equalTo(scrollView)
            make.width.equalTo(self.view.width)
            make.height.equalTo(DeviceInfo.isPhone_X ? (self.view.height - 38 - 84) : self.view.height)
            }.configure { (view) in
                view.backgroundColor = R.color.appColor._e7c99e()
        }
        
        let basicInfoView = GameBasicInfoView().addTo(superView: containView).layout { (make) in
            make.top.left.right.equalToSuperview().inset(margin_16)
            make.height.equalTo(257)
        }
        self.basicInfoView = basicInfoView
        
        let introductionInfoView = GameIntroductionView().addTo(superView: containView).layout { (make) in
            make.top.equalTo(basicInfoView.snp.bottom).offset(2)
            make.centerX.equalToSuperview()
            make.width.equalTo(basicInfoView.snp.width)
            make.bottom.equalToSuperview()
        }
        self.introductionView = introductionInfoView
        
        gameJoinView = UIImageView().addTo(superView: view).configure { (view) in
            view.image = R.image.game_join_mask()
            view.isUserInteractionEnabled = true
            }.layout { (make) in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(70)
        }
        
        enterGameButton = UIButton().addTo(superView: gameJoinView!).layout { (make) in
            make.size.equalTo(CGSize(width: 240, height: 40))
            make.center.equalToSuperview()
            }.configure { (button) in
                button.setDefaultStyle(fontSize: 15)
                button.setTitle(NSLocalizedString("enter_game", comment: "进入游戏"), for: .normal)
                button.addTarget(self, action: #selector(self.enterGameDidClicked), for: .touchUpInside)
        }
        //        containView.snp.makeConstraints({ (make) in
        //            if DeviceInfo.isPhone_X {
        //                make.bottom.equalTo(gameJoinView.snp.bottom)
        //            }else {
        //                make.bottom.equalTo(introductionInfoView.snp.bottom)
        //            }
        //        })
    }
    
    override func viewSafeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            gameJoinView!.snp.remakeConstraints({ (make) in
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview().inset(view.safeAreaInsets.bottom)
                make.height.equalTo(70)
            })
        }
    }
    
    override func viewModelOutputDrive(output: ViewModelToViewOutput) {
        let detailOutput = output as! GameDetailOutput
        detailOutput.gameDetailInfo.drive(onNext: { [weak self] detailEntity in
            guard let entity = detailEntity else {
                return
            }
            self?.basicInfoView?.bindToEntity(entity)
            self?.introductionView?.bindToEntity(entity)
        }).disposed(by: disposeBag)
        
        detailOutput.enterGame.drive(onNext: {[unowned self] response in
            let waitingView = EnterGameWaitingView.waitingView(from: AppDelegate.keyWindow())
            
            guard let (nickName, signature, timestamp, gameAddr, mapName, mapURL) = response else {
                waitingView?.dismiss(animate: true)
                BlockyAlert.show(title: R.string.localizable.notification(), message: NSLocalizedString("enter_game_fail_retry", comment: "进入游戏失败，请重试"))
                return
            }
            
            waitingView?.dismiss(animate: false)
            
            AnalysisManager.analysisEnterGame(self.params as! String) //统计小游戏进入
            
            // 进入游戏
            let gameController = BMGameViewController.init()
            gameController.bmDelegate = self
            gameController.userID = NSNumber.init(value: Int32(AccountInfoManager.shared.userId.value)!)
            gameController.nickName = nickName
            gameController.userToken = signature
            gameController.gameAddr = gameAddr
            gameController.mapName = mapName
            gameController.mapUrl = mapURL
            gameController.gameTimestamp = NSNumber.init(value: timestamp)
            gameController.language = Locale.current.identifier
            gameController.gameType = self.params as! String
            self.present(gameController, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
    }
    
    @objc fileprivate func enterGameDidClicked() {
        let gameID = params as! String
        if AccountStatusManager.shared.statusVariable.value == .visit, (gameID == "g1014" || gameID == "g1015") { // 警匪游戏需要登录才能玩
            BlockyAlert.show(title: R.string.localizable.notification(), message: R.string.localizable.play_game_after_login(), showCancel: false).done(closure: { (_) in
                AppDelegate.globalServive().pushViewModel(AccountPageViewModel.self, params: AccountPageController.AccountType.login, animated: true)
            })
            return
        }
        EnterGameWaitingView.init().show(inView: AppDelegate.keyWindow())
        AnalysisManager.trackEvent(AnalysisManager.Event.click_quickaccess, parameters: ["gameID" : gameID])
        enterGamePublish.onNext(gameID)
    }
}

extension GameDetailViewController: BMGameViewControllerDelegate {
    func gameViewControllerdidDismissed(_ controller: BMGameViewController!, autoStartNextGame isAutoStart: Bool) {
        guard !isAutoStart else {
            enterGameDidClicked()
            return
        }
        
        guard AccountStatusManager.shared.statusVariable.value == .logIn else { return }
        
        RechargeNetServer.fetchProperty().mapModel(type: UserPropertyModel.self).subscribe(onSuccess: { (propertyModel) in
            AccountPropertyManager.shared.updateProperty(propertyModel)
        }).disposed(by: disposeBag)
    }
    
}

struct GameDetailInput: ViewToViewModelInput {
    let gameIdInput: Driver<String>
    let enterGameInput: Driver<String>
    
    init(view: BaseViewController) {
        let gameDetailView = view as! GameDetailViewController
        
        gameIdInput = Driver.just(gameDetailView.params as! String)
        enterGameInput = gameDetailView.enterGamePublish.asDriver(onErrorJustReturn: "g1001")
    }
}
