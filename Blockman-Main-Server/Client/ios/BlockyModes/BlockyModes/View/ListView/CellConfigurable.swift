//
//  CellConfigurable.swift
//  BlockyModes
//
//  Created by KiBen on 2018/2/5.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import Foundation

protocol CellConfigurable {
    func bindToCellEntity(_ entity: ItemEntityConfigurable, indexPath: IndexPath)
}
