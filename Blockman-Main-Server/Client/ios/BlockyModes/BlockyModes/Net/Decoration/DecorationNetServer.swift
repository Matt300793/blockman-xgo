//
//  DecorationNetServer.swift
//  BlockyModes
//
//  Created by KiBen on 2018/1/4.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import Foundation
import RxSwift
import Moya

class DecorationNetServer {
    class func fetchCurrentUsingDecorations() -> Single<[String : Any]> {
        return NetServer.requestWithTarget(Decoration.fetchCurrentUsingDecorations(), showToast: false)
    }
    
    class func fetchDecorations(category: Int) -> Single<[String : Any]> {
        return NetServer.requestWithTarget(Decoration.fetchDecorationsWithCategory(category), showToast: false)
    }
    
    class func fetchVIPDecorations(category: Int) -> Single<[String : Any]> {
        return NetServer.requestWithTarget(Decoration.fetchVIPDecorationsWithCategory(category), showToast: false)
    }
    
    class func updateUsingDecoration(id: Int) -> Single<[String : Any]> {
        return NetServer.requestWithTarget(Decoration.updateUsingDecoration(id), showToast: true)
    }
    
    class func deleteUsingDecoration(id: Int) -> Single<[String : Any]> {
        return NetServer.requestWithTarget(Decoration.deleteUsingDecoration(id), showToast: true)
    }
}
