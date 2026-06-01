//
//  GameIntroductionView.swift
//  BlockyModes
//
//  Created by KiBen on 2017/11/3.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit

class GameIntroductionView: UIView {

    lazy var introductionAttribute: [String : Any] = {
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.alignment = .left
        paraStyle.lineSpacing = 10
        return [NSFontAttributeName : UIFont.size14, NSParagraphStyleAttributeName : paraStyle, NSForegroundColorAttributeName : R.color.appColor._666666()]
    }()
    
    private weak var introductionTextView: UITextView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = R.color.appColor._fae7ca()
        
        let seperatorLine = UIView().addTo(superView: self).configure { (view) in
            view.backgroundColor = R.color.appColor._7a4e38()
        }.layout { (make) in
            make.left.top.equalToSuperview().offset(margin_16)
            make.size.equalTo(CGSize(width: 2, height: 14))
        }
        
        let _ = UILabel().addTo(superView: self).configure { (label) in
            label.textColor = R.color.appColor._7a4e38()
            label.font = UIFont.size15
            label.text = NSLocalizedString("game_introduce", comment: "游戏介绍:")
        }.layout { (make) in
            make.left.equalTo(seperatorLine).offset(5)
            make.centerY.equalTo(seperatorLine)
        }
        
        let introductionTextView = UITextView().addTo(superView: self).configure { (textView) in
            textView.backgroundColor = UIColor.clear
            textView.isEditable = false
            textView.showsVerticalScrollIndicator = true
        }.layout { (make) in
            make.top.equalToSuperview().offset(47)
            make.left.right.bottom.equalToSuperview().inset(margin_16)
        }
        self.introductionTextView = introductionTextView
    }
    
    func bindToEntity(_ entity: GameDetailEntity) {
        introductionTextView?.attributedText = NSAttributedString.init(string: entity.gameIntroduction, attributes: introductionAttribute)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
