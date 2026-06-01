//
//  AccountPropertyManager.swift
//  BlockyModes
//
//  Created by KiBen on 2018/1/16.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import Foundation
import RxSwift
import HandyJSON

class AccountPropertyManager {
    
    let diamonds: Variable<Int>
    let golds: Variable<Int>
    
    private var propertyModel: UserPropertyModel?
    private let disposeBag = DisposeBag()
    
    public static let shared = AccountPropertyManager()
    
    init() {
        if let propertyData = BlockyUserDefaults.data(forKey: BlockyUserDefaults.accountPropertyKey) {
            let json = try? JSONSerialization.jsonObject(with: propertyData, options: .allowFragments) as! [String : Any]
            guard let propertyModel = UserPropertyModel.deserialize(from: json) else {
                diamonds = Variable(0)
                golds = Variable(0)
                return
            }
            diamonds = Variable(propertyModel.diamonds)
            golds = Variable(propertyModel.golds)
        }else {
            diamonds = Variable(0)
            golds = Variable(0)
        }
        
        NotificationCenter.default.rx.notification(Notification.Name.UIApplicationDidEnterBackground, object: self)
        .subscribe(onNext: { [unowned self] _ in
            self.storeProperty()
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(Notification.Name.UIApplicationWillTerminate, object: self)
        .subscribe(onNext: { [unowned self] _ in
            self.storeProperty()
        }).disposed(by: disposeBag)
    }
    
    // 增加钻石,金币数量
    public func increase(diamonds: Int, golds: Int) {
        updateDiamonds(self.diamonds.value + diamonds)
        updateGolds(self.golds.value + golds)
    }
    
    // 减少钻石数,金币数量
    public func decrease(diamonds: Int, golds: Int) {
        updateDiamonds(self.diamonds.value - diamonds)
        updateGolds(self.golds.value - golds)
    }
    
    // 直接更新钻石总数
    public func updateDiamonds(_ totalDiamonds: Int) {
        propertyModel?.diamonds = totalDiamonds
        diamonds.value = totalDiamonds
    }
    
    // 直接更新金币总数
    public func updateGolds(_ totalGolds: Int) {
        propertyModel?.golds = totalGolds
        golds.value = totalGolds
    }
    
    public func update(diamonds: Int, golds: Int) {
        updateGolds(golds)
        updateDiamonds(diamonds)
    }
    
    public func updateProperty(_ property: UserPropertyModel) {
        
        propertyModel = property
        
        diamonds.value = property.diamonds
        golds.value = property.golds
    }
    
    private func storeProperty() {
        guard let json = propertyModel?.toJSON()  else { return }

        let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        BlockyUserDefaults.storeData(data, forKey: BlockyUserDefaults.accountPropertyKey)
    }
}
