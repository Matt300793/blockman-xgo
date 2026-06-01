//
//  BMCollectionViewCell.swift
//  BlockyModes
//
//  Created by KiBen on 2018/2/6.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit

class BMCollectionViewCell: UICollectionViewCell, CellConfigurable {
    
    func bindToCellEntity(_ entity: ItemEntityConfigurable, indexPath: IndexPath) {
        DebugLog("默认空实现，子类去实现具体逻辑")
    }
}
