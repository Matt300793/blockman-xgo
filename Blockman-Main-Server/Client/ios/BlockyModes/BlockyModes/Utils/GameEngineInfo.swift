//
//  GameEngine.swift
//  BlockyModes
//
//  Created by KiBen on 2018/1/22.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import Foundation

struct GameEngineInfo {
    
    public static var version: Int  {
        var bundlePath = Bundle.main.resourcePath!
        bundlePath.append("/BlockMod/Media/engineVersion.json")
        guard let data = try? Data.init(contentsOf: URL.init(fileURLWithPath: bundlePath)) else {
            return 10000
        }
        let engineVersionDict = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : Any]
        return engineVersionDict["engineVersion"] as! Int
    }
}
