//
//  DefaultStyle.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2017/10/19.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation
import UIKit

let margin_16: CGFloat = 16.0
let margin_14: CGFloat = 14.0
let margin_12: CGFloat = 12.0
let margin_10: CGFloat = 10.0

extension UIButton {
    
    public func setDefaultStyle(fontSize: CGFloat = 12) {
        self.setBackgroundImage(R.image.common_btn_normal(), for: .normal)
        self.setBackgroundImage(R.image.common_btn_highlight(), for: .highlighted)
        self.setBackgroundImage(R.image.common_btn_disable(), for: .disabled)
        self.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        self.setTitleColor(R.color.appColor._FEFEFE(), for: .normal)
    }
}

extension UITextField {
    
    public func setDefaultStyle(placeHolder: String, isSecure: Bool) {
        self.font = UIFont.size14
        self.borderStyle = .none
        self.keyboardType = .asciiCapable
        self.clearButtonMode = .whileEditing
        self.isSecureTextEntry = isSecure
        self.backgroundColor = R.color.appColor._fae7ca()
        self.textColor = R.color.appColor._333333()
        self.attributedPlaceholder = NSAttributedString.init(string: placeHolder, attributes: [NSForegroundColorAttributeName : R.color.appColor._aaaaaa(), NSFontAttributeName : UIFont.size14])
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 50))
        leftView.backgroundColor = UIColor.clear
        self.leftView = leftView
        self.leftViewMode = .always
    }
}

