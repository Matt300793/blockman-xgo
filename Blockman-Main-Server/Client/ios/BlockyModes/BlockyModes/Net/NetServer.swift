//
//  NetServer.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/21.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation
import UIKit
import HandyJSON
import Moya
import Result
import RxSwift

#if BLOCKY_OVERSEA
    #if DEBUG
        let serverHost = "http://mods.sandboxol.com" //"http://120.92.158.119"
    #else
        let serverHost = "http://mods.sandboxol.com"
    #endif
#else
    #if DEBUG
        let serverHost = "http://120.92.158.119"
    #else
        let serverHost = "http://mods.sandboxol.com"
    #endif
#endif

let apiVersion = "v1"

// MARK: Error
enum BlockyError: Int, Swift.Error {
    // User
    case nicknameInvalid = 3
    case noPermission = 7
    case nicknameExist = 1003
    case accountExist = 101
    case accountNotExist = 102
    case phoneHasBinded = 103
    case phoneNotBind = 104
    case smsSendFailed = 105
    case hasBindedPhone = 106
    case verificationCodeError = 107
    case passwordError = 108
    case emailPatternError = 111
    case emailNotValid = 112
    case emailHasBeenBind = 113
    case userHasBindEmail = 114
    case emailNotBindToUser = 116
    case profileNotExist = 1002
    
    // Game
    case gameNotExist = 2002
    case alreadyAppreciated = 2005
    case withoutPlayGame = 2008
    
    // Decoration
    case systemNoDecoration = 4003 //系统不存在该装饰信息
    case userNoDecoration = 4005 // 用户没有该装饰信息
    case notUseDecorationInLowVIP = 6001 // 用户VIP等级不足, 无法使用
    
    // Decoration Shop
    case productNotExist = 5002 // 没有此商品
    case productSellOut = 5004 //商品卖完
    
    // Pay
    case transactionHasVerified = 5003 // 订单已处理

    // DailyTask
    case hasSignedIn = 6002 // 已签到
    
    // HTTP
    case parametersError = 400
    case unauthorized = 401
    case serverNotFound = 404
    case requestMethodError = 405
    case serverInnerError = 500
    
    case unKnown = -1
}

// MARK: Plugin
class RequestLoadingPlugin: PluginType {
    func willSend(_ request: RequestType, target: TargetType) {
        var URLString = target.baseURL.absoluteString
        URLString.append(target.path)
        
        var parameters: [String : Any] = [:]
        switch target.task {
        case let .requestParameters(parameters: param, encoding: _):
            parameters += param
        default:
            break
        }
        
        guard let headers = target.headers else { return DebugLog("request ################\n URL: \(URLString) \n param: \(parameters) \n without header \n\n")}
        
        DebugLog("request start ################\n URL: \(URLString) \n param: \(parameters) \n header: \(headers) \n\n")
    }
    
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        
        var responseDict: [String : Any] = [:]
        
        switch result {
        case let .success(response):
            do {
                responseDict = try JSONSerialization.jsonObject(with: response.data, options: .allowFragments) as! [String : Any]
            }catch let error as NSError {
                print("responseData 解析失败, \(error.description)")
            }
            
        default:
            break
        }
        DebugLog("response did ################\n  \(responseDict)")
    }
}

// MARK: BlockyResult
enum BlockyResult {
    case success
    case fail(BlockyError)
}

// MARK: NetServer
class NetServer {
    
    static let networkActivityPlugin = NetworkActivityPlugin { type in
        switch type {
        case .began:
            /// 状态栏转圈
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        case .ended:
            /// 状态栏停止转圈
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }

    static let provider = RxMoyaProvider<MultiTarget>(plugins: [networkActivityPlugin, RequestLoadingPlugin()])
    
    class func requestWithTarget(_ target: TargetType, showToast: Bool = true) -> Single<[String : Any]> {
        if showToast {
            BlockyHUD.showLoading(inView: AppDelegate.currentNavigationController().topViewController?.view ?? AppDelegate.keyWindow())
        }
        return provider.request(MultiTarget.init(target)).do(onNext: { response in
            if showToast {
                BlockyHUD.hide(forView: AppDelegate.currentNavigationController().topViewController?.view ?? AppDelegate.keyWindow())
            }
            try responseParse(response)
        }, onError: { error in
            DebugLog("response Error \(error)")
            if showToast {
                BlockyHUD.hide(forView: AppDelegate.currentNavigationController().topViewController?.view ?? AppDelegate.keyWindow())
            }
            throw BlockyError.unKnown
        }).filterSuccessfulStatusCodes().mapJSON().filterBlockyErrorCode()
    }
    
    class func responseParse(_ response: Response) throws {
        
        guard response.statusCode != 200 else {
            return
        }
        
        if response.statusCode == 401, !AccountPageController.isPresented {
            AccountPageController.isPresented = true
            AppDelegate.globalServive().presentViewModel(AccountPageViewModel.self, params: AccountPageController.AccountType.login, animated: true, completion: nil)
            BlockyHUD.showText(R.string.localizable.authorization_fail_log_in(), inView: AppDelegate.keyWindow())
            throw BlockyError.unauthorized
        }
        
        let json = try JSONSerialization.jsonObject(with: response.data, options: .allowFragments) as? [String : Any]
        if let json = json {
            DebugLog("Error: \(json)")
        }
        
        guard let error = BlockyError(rawValue: response.statusCode) else { throw BlockyError.unKnown }
        throw error
    }
}






