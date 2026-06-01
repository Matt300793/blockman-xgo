//
//  UnderlineInputView.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/18.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit
import SnapKit

class UnderlineInputView: UIView {

    private(set) lazy var underline: UIView = {
        let view = UIView()
        view.backgroundColor = R.color.appColor.separator()
        return view
    }()
    
     private(set) lazy var textField : UITextField! = {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.textColor = R.color.appColor.white()
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    
    init(frame: CGRect, placeHolder: String? = nil, secureTextEntry: Bool = false) {
        super.init(frame: frame)
        
        self.addSubview(underline)
        underline.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.left.right.bottom.equalToSuperview()
        }
        
        self.addSubview(textField)
        if let placeHolder = placeHolder {
            let attributedPlaceholder = NSMutableAttributedString.init(string: placeHolder, attributes: [NSForegroundColorAttributeName : R.color.appColor.text_normal(), NSFontAttributeName : UIFont.systemFont(ofSize: 15)])
            if placeHolder.contains("(") {
                let string = placeHolder as NSString
                attributedPlaceholder.addAttribute(NSFontAttributeName, value: UIFont.size11, range: NSMakeRange(string.range(of: "(").location, string.length - string.range(of: "(").location))
            }
            textField.attributedPlaceholder = attributedPlaceholder
        }
        textField.keyboardType = .asciiCapable
        textField.isSecureTextEntry = secureTextEntry
        textField.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview()
            make.bottom.equalTo(underline).inset(2)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resignResponder() {
        textField.resignFirstResponder()
    }
}
