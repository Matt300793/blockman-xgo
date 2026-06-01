//
//  ThirdLoginView.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/19.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit

class ThirdLoginItem: UIView {
    
    lazy private(set) var iconButton: UIButton = {
        return UIButton()
    }()
    
    lazy private(set) var titleLab: UILabel = {
        let title = UILabel()
        title.font = UIFont.systemFont(ofSize: 10)
        title.textColor = R.color.appColor.text_normal()
        title.textAlignment = .center
        return title
    }()
    
    init(frame: CGRect, icon: UIImage?, title: String?) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clear
        iconButton.setBackgroundImage(icon, for: .normal)
        titleLab.text = title
        
        self.addSubview(iconButton)
        iconButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 48, height: 48))
            make.top.centerX.equalToSuperview()
        }
        
        self.addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.top.equalTo(iconButton.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class ThirdLoginView: UIView {
    
    lazy var faceBookItem: ThirdLoginItem = {
        return ThirdLoginItem(frame: .zero, icon: R.image.login_facebook(), title: "Facebook")
    }()
    
    lazy var twitterItem: ThirdLoginItem = {
        return ThirdLoginItem(frame: .zero, icon: R.image.login_twitter(), title: "Twitter")
    }()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = R.color.appColor.mainBackground()
        
        let thirdLoginTitle = UILabel().config(text: NSLocalizedString("third_party_log_in", comment: "第三方账号登录"), textColor: R.color.appColor.text_normal(), font: UIFont.size14)
        thirdLoginTitle.backgroundColor = R.color.appColor.mainBackground()
        self.addSubview(thirdLoginTitle)
        thirdLoginTitle.snp.makeConstraints { (make) in
            make.top.centerX.equalToSuperview()
        }
        
        let line  = UIView()
        line.backgroundColor = R.color.appColor.text_normal()
        self.insertSubview(line, belowSubview: thirdLoginTitle)
        line.snp.makeConstraints { (make) in
            make.width.equalTo(thirdLoginTitle.bounds.size.width + 20)
            make.height.equalTo(1)
            make.centerY.centerX.equalTo(thirdLoginTitle)
        }
        
        let itemWidth: CGFloat = 55.0
        let margin = (UIScreen.main.bounds.width - 2 * itemWidth) / 3
        self.addSubview(faceBookItem)
        faceBookItem.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: itemWidth, height: 65))
            make.left.equalToSuperview().offset(margin)
            make.centerY.equalToSuperview()
        }
        
        self.addSubview(twitterItem)
        twitterItem.snp.makeConstraints { (make) in
            make.size.centerY.equalTo(faceBookItem)
            make.right.equalToSuperview().inset(margin)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
