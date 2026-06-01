//
//  ViewModelMapper.swift
//  BlockyModes
//
//  Created by KiBen on 2018/2/8.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import Foundation

protocol ViewModelMapper {
    static var mappedController: BaseViewController.Type {get}
}
