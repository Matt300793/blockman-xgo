//
//  MainTabBar.swift
//  BlockyModes
//
//  Created by KiBen on 2018/3/26.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit

class MainTabBar: UITabBar {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        barTintColor = R.color.appColor.black()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
