//
//  DecorationConfigurable.swift
//  BlockyModes
//
//  Created by KiBen on 2018/1/4.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import Foundation

protocol DecorationConfigurable {
    
    func configure(withContent content: Any?)
    
    func set(selected: Bool)
}
