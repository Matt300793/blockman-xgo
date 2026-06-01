//
//  UILabel+Extension.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/19.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit

extension UILabel {
    func config(text: String?, textColor: UIColor?, textAlignment: NSTextAlignment = .left, font: UIFont = UIFont.systemFont(ofSize: 12)) -> UILabel {
        self.text = text
        self.textColor = textColor
        self.font = font
        self.textAlignment = textAlignment
        self.sizeToFit()
        return self
    }
}
