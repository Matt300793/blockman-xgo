//
//  MessageNotificationViewController.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/24.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit

class MessageNotificationViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "消息提醒"
    }

    override func createAndLayoutChildViews() {
        super.createAndLayoutChildViews()
        
        // 消息推送
        let pushContainV = UIView()
        pushContainV.backgroundColor = R.color.appColor._fae7ca()
        view.addSubview(pushContainV)
        pushContainV.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(50)
        }
        
        let messagePushLab = UILabel().config(text: "开启消息推送通知", textColor: R.color.appColor._333333(), font: UIFont.size15)
        pushContainV.addSubview(messagePushLab)
        messagePushLab.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        let messagePushSwitch = UISwitch()
        pushContainV.addSubview(messagePushSwitch)
        messagePushSwitch.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
        
        // 私信通知
        let privateMsgContainV = UIView()
        privateMsgContainV.backgroundColor = R.color.appColor._fae7ca()
        view.addSubview(privateMsgContainV)
        privateMsgContainV.snp.makeConstraints { (make) in
            make.size.centerX.equalTo(pushContainV)
            make.top.equalTo(pushContainV).offset(1)
        }
        
        let privateMsgLab = UILabel().config(text: "私信消息通知", textColor: R.color.appColor._333333(), font: UIFont.size15)
        privateMsgContainV.addSubview(privateMsgLab)
        privateMsgLab.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        let privateMsgSwitch = UISwitch()
        privateMsgContainV.addSubview(privateMsgSwitch)
        privateMsgSwitch.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
    }
}
