//
//  BMTableViewCell.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2018/2/5.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit

class BMTableViewCell: UITableViewCell, CellConfigurable {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func bindToCellEntity(_ entity: ItemEntityConfigurable, indexPath: IndexPath) {
        DebugLog("默认空实现，子类去实现具体逻辑")
    }
}
