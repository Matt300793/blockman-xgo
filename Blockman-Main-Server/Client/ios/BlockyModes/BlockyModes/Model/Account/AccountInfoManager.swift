//
//  AccountInfoManager.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/25.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation
import RxSwift
import HandyJSON

let UserDefaultsAccountPasswordKey = "UserDefaultsAccountPasswordKey"
let UserDefaultsUserInfoKey = "UserDefaultsUserInfoKey"
let UserDefaultsVisitorInfoKey = "UserDefaultsVisitorInfoKey"

class AccountInfoManager {

    enum Gender: Int {
        case male = 1
        case female = 2
    }
    
    let disposeBag = DisposeBag()
    static let shared = AccountInfoManager()
    
    let nickname = Variable("")
    let userId = Variable("")
    let introduction = Variable("")
    let gender = Variable(Gender.male)
    let birthDay = Variable("")
    let genderImage = Variable(UIImage())
    let portraiUrl = Variable("")
    let phone = Variable("")
    let email = Variable("")
    let token = Variable("")
    let vipExpireDate = Variable("")
    let vip = Variable(0)
    let loginFromThird = Variable(false)
    
    private var userInfo: UserInfoModel?
    private var visitorInfo: VisitorInfoModel?
    
    init() {
        // MARK: 订阅账号状态变化
        AccountStatusManager.shared.statusVariable.asObservable().subscribe(onNext: { status in
            switch status {
            case .logIn:
                self.updatePropertiesWithUserInfo()
            case .visit:
                self.updatePropertiesWithVisitorInfo()
            }
        })
        .disposed(by: disposeBag)
    }
    
    // MARK: 判断本地是否有登录账号信息
    class func isExistUserInfoInLocal() -> Bool {
        if let _ = UserDefaults.standard.data(forKey: UserDefaultsUserInfoKey) {
            return true
        }
        return false
    }
    
    // MARK: 判断本地是否有游客账号信息
    class func isExistVisitorInfoInLocal() -> Bool {
        if let _ = UserDefaults.standard.data(forKey: UserDefaultsVisitorInfoKey) {
            return true
        }
        return false
    }
    
    // MARK: 更新头像URL
    func updatePortraitUrl(_ portraiUrl: String) {
        userInfo?.picUrl = portraiUrl
        self.portraiUrl.value = portraiUrl
        storeUserInfoInUserDefaults()
    }
    
    // MARK: 是否绑定了手机
    func hasBindedPhone() -> Bool {
        guard let telephone = userInfo?.telephone else { return false }
        if telephone.isEmpty {
            return false
        }
        return true
    }
    
    // MARK: 是否绑定了邮箱
    func hasBindedEmail() -> Bool {
        guard let email = userInfo?.email else { return false }
        if email.isEmpty {
            return false
        }
        return true
    }
    
    // MARK: 更新vip等级
    func updateVIP(level: Int, expireDate: String) {
        userInfo?.vip = level
        userInfo?.expireDate = expireDate
        vip.value = level
        vipExpireDate.value = expireDate
        storeUserInfoInUserDefaults()
    }
    
    // MARK: 更新绑定的手机号
    func updateBindedPhone(_ phone: String) {
        userInfo?.telephone = phone
        self.phone.value = phone
        storeUserInfoInUserDefaults()
    }
    
    // MARK: 移除已绑定的手机号
    func removeBindedPhone() {
        userInfo?.telephone = ""
        phone.value = NSLocalizedString("unbind", comment: "未绑定")
        storeUserInfoInUserDefaults()
    }
    
    // MARK: 更新绑定的邮箱
    func updateBindEmail(_ email: String) {
        userInfo?.email = email
        self.email.value = email
        storeUserInfoInUserDefaults()
    }
    
    // MARK: 移除已绑定的邮箱
    func removeBindEmail() {
        userInfo?.email = ""
        email.value = NSLocalizedString("unbind", comment: "未绑定")
        storeUserInfoInUserDefaults()
    }
    
    // MARK: 返回账号密码，格式为[account, password]
    func accountPassword() -> [String]? {
        guard let cacheData = UserDefaults.standard.object(forKey: UserDefaultsAccountPasswordKey) as? Data else {
             return nil
        }
        let accountPasswordString = String.init(data: cacheData, encoding: String.Encoding.utf8)!
        return accountPasswordString.components(separatedBy: "-")
    }
    
    // MARK: 存储登录用户信息
    func storeUserInfo(_ userInfo : UserInfoModel) {
        self.userInfo = userInfo
        storeAccountPassword()
        storeUserInfoInUserDefaults()
        updatePropertiesWithUserInfo()
    }
    
    // MARK: 更新登录用户信息
    func updateUserInfo(_ infoJson: [String : Any]) {
        checkUserInfo()
        if let userInfo = userInfo {
            var originInfo = userInfo
            JSONDeserializer.update(object: &originInfo, from: infoJson)
            storeUserInfoInUserDefaults()
        }
        updatePropertiesWithUserInfo()
    }
    
    // MARK: 存储游客用户信息
    func storeVisitorInfo(_ visitorInfo: VisitorInfoModel) {
        self.visitorInfo = visitorInfo
        storeVisitorInfoInUserDefaults()
        updatePropertiesWithVisitorInfo()
    }
    
    // MARK: 检查登录用户信息
    private func checkUserInfo() {
        if userInfo == nil {
            if let data = UserDefaults.standard.data(forKey: UserDefaultsUserInfoKey) {
                let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : Any]
                userInfo = UserInfoModel.deserialize(from: json)
            }
        }
    }
    
    // MARK: 检查游客用户信息
    private func checkVisitorInfo() {
        if visitorInfo == nil {
            if let data = UserDefaults.standard.data(forKey: UserDefaultsVisitorInfoKey) {
                let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : Any]
                visitorInfo = VisitorInfoModel.deserialize(from: json)
            }
        }
    }
    
    // MARK: 使用登录用户信息，更新对外使用的属性
    private func updatePropertiesWithUserInfo() {
        self.checkUserInfo()
        if let userInfo = userInfo {
            userId.value = "\(userInfo.userId)"
            nickname.value = userInfo.nickName
            introduction.value = userInfo.details
            gender.value = userInfo.sex == 1 ? Gender.male : Gender.female
            genderImage.value = userInfo.sex == 1 ? R.image.common_male()! : R.image.common_female()!
            birthDay.value = userInfo.birthday.isEmpty ?  NSLocalizedString("please_select", comment: "请选择") : userInfo.birthday
            phone.value = userInfo.telephone.isEmpty ? NSLocalizedString("unbind", comment: "未绑定") : userInfo.telephone
            email.value = userInfo.email.isEmpty ? NSLocalizedString("unbind", comment: "未绑定")  : userInfo.email
            portraiUrl.value = userInfo.picUrl
            token.value = userInfo.accessToken
            vip.value = userInfo.vip
            vipExpireDate.value = userInfo.expireDate
            loginFromThird.value = userInfo.loginFromThird
        }
    }
    
    // MARK: 使用游客用户信息，更新对外使用的属性
    private func updatePropertiesWithVisitorInfo() {
        self.checkVisitorInfo()
        if let visitorInfo = visitorInfo {
            userId.value = visitorInfo.id!
            nickname.value = visitorInfo.nickName!
            token.value = visitorInfo.accessToken!
        }else {
            nickname.value = "游客"
        }
        gender.value = Gender.male
        genderImage.value = UIImage()
        portraiUrl.value = ""
        introduction.value = ""
        vip.value = 0
        vipExpireDate.value = ""
    }
    
    // MARK: 存储用户账号密码
    private func storeAccountPassword() {
        guard let userInfo = userInfo else { return }
        guard !userInfo.account.isEmpty && !userInfo.password.isEmpty else { return }
        let accountPasswordData = (userInfo.account + "-" + userInfo.password).data(using: String.Encoding.utf8)!
        UserDefaults.standard.set(accountPasswordData, forKey: UserDefaultsAccountPasswordKey)
    }
    
    private func storeVisitorInfoInUserDefaults() {
        do {
            guard let json = visitorInfo?.toJSON() else { return }
            
            let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            UserDefaults.standard.set(data, forKey: UserDefaultsVisitorInfoKey)
        }catch {
            DebugLog("storeVisitorInfoInUserDefaults catch")
        }
    }
    
    private func storeUserInfoInUserDefaults() {
        do {
            guard let json = userInfo?.toJSON() else { return }
            
            let data  = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            UserDefaults.standard.set(data, forKey: UserDefaultsUserInfoKey)
        }catch {
            DebugLog("storeUserInfoInUserDefaults catch")
        }
    }
}
