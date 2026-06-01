//
//  Single+Net.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2017/11/4.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation
import RxSwift
import HandyJSON

extension Single {
    // json -> model
    func mapModel<T: HandyJSON>(type: T.Type) -> Single<T> {
        return self.map { response -> T in
            
            let jsonDict = response as? [String : Any]
            guard let model = T.deserialize(from: jsonDict, designatedPath: "data") else {
                throw BlockyError.unKnown
            }
            return model
            } as! Single<T>
    }
}

extension Single {
    // [json] -> [model]
    func mapModelArray<T: HandyJSON>(type: T.Type) -> Single<[T]> {
        return self.map { response -> [T] in
            
            let jsonDict = response as! [String : Any]
            guard let jsonArray = jsonDict["data"] as? [[String : Any]] else {
                return []
            }
            return [T].deserialize(from: jsonArray) as! [T]
            
            } as! Single<[T]>
    }
}

extension Single {
    func filterBlockyErrorCode() -> Single<[String : Any]> {
        return self.map({response -> [String : Any] in
            let json = response as! [String : Any]
            guard let code = json["code"] as? Int else {
                return json
            }
            
            guard code != 1, code != 1002, code != 5006 else {
                return json
            }
            
            // throw error
            guard let error = BlockyError(rawValue: code) else {
                throw BlockyError.unKnown
            }
            throw error
        }) as! Single<[String : Any]>
    }
}
