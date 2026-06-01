//
//  ConfigurationNetServer.swift
//  BlockyModes
//
//  Created by KiBen on 2017/12/28.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit
import Moya
import RxSwift

class ConfigurationNetServer {

    class func checkAppUpdate() -> Single<[String : Any]> {
        return NetServer.requestWithTarget(Configuration.checkAppUpdate, showToast: false)
    }
    
    class func fetchAppUpdateInfo() -> Single<[String : Any]> {
        return NetServer.requestWithTarget(Configuration.fetchAppUpdateInfo, showToast: false)
    }
}
