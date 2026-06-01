//
//  HomePageViewModel.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/16.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation
import RxSwift

class HomePageViewModel: TabBarViewModel {
    
    override class var mappedController: BaseViewController.Type {return HomePageViewController.self}
    
    private let disposeBag = DisposeBag()
    
    public func checkVisitorInfo() {
        if AccountInfoManager.isExistVisitorInfoInLocal() { //本地有游客信息缓存
            return
        }
        
        // 加载游客信息
        UserNetServer.fetchVisitorInfo().mapModel(type: VisitorInfoModel.self)
            .map({ visitorInfo -> Bool in
                AccountInfoManager.shared.storeVisitorInfo(visitorInfo)
                return true
            })
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { success in
                guard success else {
                    AppDelegate.globalServive().pushViewModel(AccountPageViewModel.self, params: AccountPageController.AccountType.login, animated: true)
                    return
                }
            })
            .disposed(by: disposeBag)
    }
    
    public func fetchProperty() {
        AccountStatusManager.shared.statusVariable.asObservable().do(onNext: { (status) in
            if status == AccountStatusManager.Status.visit {
                AccountPropertyManager.shared.update(diamonds: 0, golds: 0)
            }
        }).filter({ status in
            status == AccountStatusManager.Status.logIn
        }).flatMap { _ in
            RechargeNetServer.fetchProperty().mapModel(type: UserPropertyModel.self)
        }.subscribe(onNext: { propertyModel in
            AccountPropertyManager.shared.updateProperty(propertyModel)
        }).disposed(by: disposeBag)
    }
}

