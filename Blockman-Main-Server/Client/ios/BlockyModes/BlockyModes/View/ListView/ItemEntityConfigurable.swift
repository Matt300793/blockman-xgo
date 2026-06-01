//
//  ItemEntityConfigurable.swift
//  BlockyModes
//
//  Created by KiBen on 2018/2/5.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import Foundation

protocol ItemEntityConfigurable {
    var itemHeight: CGFloat {get}
    
    var itemSize: CGSize {get}
    
}

extension ItemEntityConfigurable {
    
    var itemHeight: CGFloat {
        return 44.0
    }
    
    var itemSize: CGSize {
        return CGSize(width: 44.0, height: 44.0)
    }
}
